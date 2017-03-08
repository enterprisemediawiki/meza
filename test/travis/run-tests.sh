#!/bin/bash
#
#

# -e: kill script if anything fails
# -u: don't allow undefined variables
# -x: debug mode; print executed commands
set -eux

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
	api_url_base="http://127.0.0.1:8080/$wiki_id/api.php?action=query&meta=siteinfo&format=json"

	api_url_siteinfo="$api_url_base?action=query&meta=siteinfo&format=json"
	api_url_ve="$api_url_base?action=visualeditor&format=json&paction=parse&page=Main_Page&uselang=en"

	${docker_exec[@]} curl -L "$api_url_siteinfo"
	${docker_exec[@]} curl -L "$api_url_siteinfo" \
	    | grep -q "\"sitename\":\"$wiki_name\"," \
	    && (echo '$wiki_name API test: pass' && exit 0) \
	    || (echo '$wiki_name API test: fail' && exit 1)

	# Verify Parsoid is working
	${docker_exec[@]} curl -L "$api_url_ve" | jq '.visualeditor.result == "success"' \
		&& (echo 'VisualEditor PASS' && exit 0) || (echo 'VisualEditor FAIL' && exit 1)

	# Verify an indices exist for this wiki
	curl "http://127.0.0.1:9200/_stats/index,store" | jq ".indices | has(\"wiki_${wiki_id}_content_first\")" \
		&& (echo 'Elasticsearch PASS' && exit 0) || (echo 'Elasticsearch FAIL' && exit 1)
	curl "http://127.0.0.1:9200/_stats/index,store" | jq ".indices | has(\"wiki_${wiki_id}_general_first\")" \
		&& (echo 'Elasticsearch PASS' && exit 0) || (echo 'Elasticsearch FAIL' && exit 1)

}

# Report docker version just in case we run into issues in the future, and we
# want to be able to track how things have changed
docker -v

# SETUP CONTAINER
# Run container in detached state, capture container ID
container_id=$(mktemp)
docker run --detach --volume="${PWD}":/opt/meza \
	--add-host="localhost:127.0.0.1" ${run_opts} \
	"${docker_repo}" "${init}" > "${container_id}"
container_id=$(cat ${container_id})

# Wrap all the `docker exec ...` in an array for clarity
docker_exec_lite=( docker exec "$container_id" )
docker_exec=( docker exec --tty "$container_id" env TERM=xterm )

# Capture args for cURLing for status codes
curl_args=( curl --write-out %{http_code} --silent --output /dev/null )


# Make sure firewalld installed and docker0 interface is in zone public
# Discovered thanks to https://github.com/docker/docker/issues/16137
# Note this was only observed on Docker on Travis CI, not on Docker on a CentOS
# or Ubuntu 14.04 host. Only tested on new version of Docker (docker-ce version
# 17.something), whereas Travis is on 1.12.something.
${docker_exec[@]} yum -y install firewalld
${docker_exec[@]} systemctl start firewalld
${docker_exec[@]} firewall-cmd --permanent --zone=public --change-interface=docker0

# Docker image "jamesmontalvo3/meza-docker-test-max:latest" has mediawiki and
# several extensions pre-cloned, but not in the correct location. Move them
# into place. For some reason gives exit code 129 on Travis sometimes. Force
# non-failing exit code.
${docker_exec[@]} mv /opt/mediawiki /opt/meza/htdocs/mediawiki || true

# Install meza command
${docker_exec[@]} bash /opt/meza/scripts/getmeza.sh

# Get IP of docker image
docker_ip=$(docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" "$container_id")

if [ "$test_type" == "monolith_from_scratch" ]; then
	echo "TEST TYPE = monolith_from_scratch"

	# Since we want to make the monolith environment without prompts, need to do
	# `meza setup env monolith` with values for required args included (fqdn,
	# db_pass, email, private_net_zone).
	${docker_exec[@]} fqdn="${docker_ip}" db_pass=1234 email=false private_net_zone=public meza setup env monolith

	# Now that environment monolith is setup, deploy/install it
	${docker_exec[@]} meza install monolith

	# TEST BASIC SYSTEM FUNCTIONALITY
	server_check

	# Demo Wiki API test
	wiki_id="demo"
	wiki_name="Demo Wiki"
	wiki_check

	# CREATE WIKI AND TEST
	${docker_exec[@]} meza create wiki-promptless monolith created "Created Wiki"

	# Created Wiki API test
	wiki_id="created"
	wiki_name="Created Wiki"
	wiki_check

	${docker_exec[@]} meza backup monolith

	${docker_exec[@]} ls /opt/meza/backups/monolith/demo

	# find any files matching *_wiki.sql in demo backups. egrep command will
	# exit-0 if something found, exit-1 (fail) if nothing found.
	${docker_exec[@]} find /opt/meza/backups/monolith/demo -name "*_wiki.sql" | egrep '.*'

elif [ "$test_type" == "monolith_from_import" ]; then

	echo "TEST TYPE = monolith_from_import"

	# TEST ANSIBLE SYNTAX. FIXME: syntax check all playbooks
	${docker_exec[@]} ansible-playbook /opt/meza/ansible/site.yml --syntax-check

	# Get test "secret" config
	${docker_exec[@]} git clone https://github.com/enterprisemediawiki/meza-test-config-secret.git /opt/meza/ansible/env/imported

	# Write the docker containers IP as the FQDN for the test config (the only
	# config setting we can't know ahead of time)
	${docker_exec[@]} sed -r -i "s/INSERT_FQDN/$docker_ip/g;" "/opt/meza/ansible/env/imported/group_vars/all.yml"

	# get backup files
	${docker_exec[@]} git clone https://github.com/jamesmontalvo3/meza-test-backups.git /opt/meza/backups/imported

	# Deploy "imported" environment with test config
	${docker_exec[@]} meza deploy imported

	# Basic system check
	server_check

	# Top Wiki API test
	wiki_id="top"
	wiki_name="Top Wiki"
	wiki_check


	# Check if title of "Test image" exists
	url_base="http://127.0.0.1/top/api.php"
	${docker_exec[@]} curl --insecure -L "$url_base?action=query&titles=File:Test_image.png&prop=imageinfo&iiprop=sha1|url&format=json" | jq '.query.pages[].title'

	# Get image url, get sha1 according to database (via API)
	img_url=$( ${docker_exec[@]} curl --insecure -L "$url_base/api.php?action=query&titles=File:Test_image.png&prop=imageinfo&iiprop=sha1|url&format=json" | jq '.query.pages[].imageinfo[0].url' )
	img_sha1=$( ${docker_exec[@]} curl --insecure -L "$url_base/api.php?action=query&titles=File:Test_image.png&prop=imageinfo&iiprop=sha1|url&format=json" | jq '.query.pages[].imageinfo[0].sha1' )

	# Retrieve image, get sha1 of file
	file_sha1=$( ${docker_exec[@]} curl --insecure -L "$img_url" | sha1sum )

	if [ "$img_sha1" == "$file_sha1" ]; then
		echo "sha1 match"
		exit 0
	else
		echo "sha1 mismatch"
		exit 1
	fi

	# FIXME: TEST FOR IDEMPOTENCE. THIS WILL FAIL CURRENTLY.

else
	echo "Bad test type: $test_type"
	exit 1
fi
