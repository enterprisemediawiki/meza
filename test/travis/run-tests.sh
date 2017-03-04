#!/bin/bash
#
#

server_check () {

	# Ensure Node.js, PHP, MariaDB installed
	${docker_exec[@]} which node
	${docker_exec[@]} node -v
	${docker_exec[@]} which php
	${docker_exec[@]} php --version
	${docker_exec[@]} which mysql
	${docker_exec[@]} mysql --version


	# HAProxy 302 redirect test
	${docker_exec[@]} ${curl_args[@]} http://127.0.0.1

	${docker_exec[@]} ${curl_args[@]} http://127.0.0.1 \
		| grep -q '302' \
		&& (echo 'HAProxy 302 redirect test: pass' && exit 0) \
		|| (echo 'HAProxy 302 redirect test: fail' && exit 1)

	# Apache (over port 8080) 200 OK test
	${docker_exec[@]} ${curl_args[@]} http://127.0.0.1:8080

	${docker_exec[@]} ${curl_args[@]} http://127.0.0.1:8080 \
		| grep -q '200' \
		&& (echo 'Apache 200 test: pass' && exit 0) \
		|| (echo 'Apache 200 test: fail' && exit 1)

}

wiki_check () {

	# Wiki API test
	api_url="http://127.0.0.1:8080/$wiki_id/api.php?action=query&meta=siteinfo&format=json"
	${docker_exec[@]} curl -L "$api_url"

	${docker_exec[@]} curl -L "$api_url" \
	    | grep -q '"sitename":"$wiki_name",' \
	    && (echo '$wiki_name API test: pass' && exit 0) \
	    || (echo '$wiki_name API test: fail' && exit 1)

}


# SETUP CONTAINER
# Run container in detached state, capture container ID
container_id=$(mktemp)
docker run --detach --volume="${PWD}":/opt/meza \
	--add-host="localhost:127.0.0.1" ${run_opts} \
	geerlingguy/docker-${distro}-ansible:latest "${init}" > "${container_id}"
container_id=$(cat ${container_id})

# Wrap all the `docker exec ...` in an array for clarity
docker_exec_lite=( docker exec "$container_id" )
docker_exec=( docker exec --tty "$container_id" env TERM=xterm )

# Capture args for cURLing for status codes
curl_args=( curl --write-out %{http_code} --silent --output /dev/null )

# Get IP of docker image
docker_ip=$(docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" "$container_id")

# Install meza command
echo "RUNNING getmeza.sh"
${docker_exec[@]} bash /opt/meza/scripts/getmeza.sh

if [ "$test_type" == "monolith_from_scratch" ]; then
	echo "RUNNING test_type = monolith_from_scratch"

	# TEST ANSIBLE SYNTAX. FIXME: syntax check all playbooks
	${docker_exec[@]} ansible-playbook /opt/meza/ansible/site.yml --syntax-check

	# Since we want to make the monolith environment without prompts, need to do
	# `meza setup env monolith` with values for required args included (fqdn,
	# db_pass, email, private_net_zone).
	echo "RUNNING meza setup env monolith"
	${docker_exec[@]} fqdn="${docker_ip}" db_pass=1234 email=false private_net_zone=public meza setup env monolith

	# Now that environment monolith is setup, deploy/install it
	echo "RUNNING meza install monolith"
	${docker_exec_lite[@]} meza install monolith

	# TEST BASIC SYSTEM FUNCTIONALITY
	echo "RUNNING server_check"
	server_check

	# Demo Wiki API test
	echo "RUNNING wiki_check for Demo Wiki"
	wiki_id="demo"
	wiki_name="Demo Wiki"
	wiki_check

	# FIXME: TEST FOR IDEMPOTENCE. THIS WILL FAIL CURRENTLY.

	# CREATE WIKI AND TEST
	echo "RUNNING meza create wiki-promptless monolith created 'Created Wiki'"
	${docker_exec[@]} meza create wiki-promptless monolith created "Created Wiki"

	# Created Wiki API test
	echo "RUNNING wiki_check for Created Wiki"
	wiki_id="created"
	wiki_name="Created Wiki"
	wiki_check

elif [ "$test_type" == "monolith_from_import" ]; then

	echo "RUNNING test_type = monolith_from_import"

	# Get test "secret" config
	${docker_exec[@]} git clone https://github.com/enterprisemediawiki/meza-test-config-secret.git /opt/meza/ansible/env/imported

	# Write the docker containers IP as the FQDN for the test config (the only
	# config setting we can't know ahead of time)
	sed -r -i "s/INSERT_FQDN/$docker_ip/g;" "$m_meza/ansible/env/imported/group_vars/all.yml"

	# Get test non-secret config
	${docker_exec[@]} git clone https://github.com/enterprisemediawiki/meza-test-config.git /opt/meza/config/local_control

	# FIXME: get backup files for test

	# Deploy "imported" environment with test config
	${docker_exec[@]} meza install imported

	# Basic system check
	server_check

	# Top Wiki API test
	wiki_id="top"
	wiki_name="Top Wiki"
	wiki_check

else
	echo "Bad test type: $test_type"
	exit 1
fi
