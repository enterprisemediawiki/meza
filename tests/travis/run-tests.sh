#!/bin/bash
#
#

# -e: kill script if anything fails
# -u: don't allow undefined variables
# -x: debug mode; print executed commands
set -eux

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
${docker_exec[@]} bash /opt/meza/src/scripts/getmeza.sh

# Get IP of docker image
docker_ip=$(docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" "$container_id")

if [ "$test_type" == "monolith_from_scratch" ]; then
	echo "TEST TYPE = monolith_from_scratch"

	# Since we want to make the monolith environment without prompts, need to do
	# `meza setup env monolith` with values for required args included (fqdn,
	# db_pass, email, private_net_zone).
	${docker_exec[@]} meza setup env monolith --fqdn="${docker_ip}" --db_pass=1234 --enable_email=false --private_net_zone=public
	# Now that environment monolith is setup, deploy/install it
	${docker_exec[@]} meza deploy monolith

	# TEST BASIC SYSTEM FUNCTIONALITY
	${docker_exec[@]} bash /opt/meza/tests/travis/server-check.sh

	# Demo Wiki API test
	${docker_exec[@]} bash /opt/meza/tests/travis/wiki-check.sh "demo" "Demo Wiki"

	# CREATE WIKI AND TEST
	${docker_exec[@]} meza create wiki-promptless monolith created "Created Wiki"

	# Created Wiki API test
	${docker_exec[@]} bash /opt/meza/tests/travis/wiki-check.sh "created" "Created Wiki"

	${docker_exec[@]} meza backup monolith

	${docker_exec[@]} ls /opt/meza/data/backups/monolith/demo

	# find any files matching *_wiki.sql in demo backups. egrep command will
	# exit-0 if something found, exit-1 (fail) if nothing found.
	${docker_exec[@]} find /opt/meza/data/backups/monolith/demo -name "*_wiki.sql" | egrep '.*'

elif [ "$test_type" == "monolith_from_import" ]; then

	echo "TEST TYPE = monolith_from_import"

	# TEST ANSIBLE SYNTAX. FIXME: syntax check all playbooks
	${docker_exec[@]} ANSIBLE_CONFIG=/opt/meza/config/core/ansible.cfg ansible-playbook /opt/meza/src/playbooks/site.yml --syntax-check

	# Get test "secret" config
	${docker_exec[@]} mkdir /opt/meza/config/local-secret
	${docker_exec[@]} git clone https://github.com/enterprisemediawiki/meza-test-config-secret.git /opt/meza/config/local-secret/imported

	# Write the docker containers IP as the FQDN for the test config (the only
	# config setting we can't know ahead of time)
	${docker_exec[@]} sed -r -i "s/INSERT_FQDN/$docker_ip/g;" "/opt/meza/config/local-secret/imported/group_vars/all.yml"

	# get backup files
	${docker_exec[@]} git clone https://github.com/jamesmontalvo3/meza-test-backups.git /opt/meza/data/backups/imported

	# Deploy "imported" environment with test config
	${docker_exec[@]} meza deploy imported

	# Basic system check
	${docker_exec[@]} bash /opt/meza/tests/travis/server-check.sh

	${docker_exec[@]} cat /etc/parsoid/localsettings.js

	# Top Wiki API test
	${docker_exec[@]} bash /opt/meza/tests/travis/wiki-check.sh "top" "Top Wiki"


	# Check if title of "Test image" exists
	url_base="http://127.0.0.1/top/api.php"
	${docker_exec[@]} curl --insecure -L "$url_base?action=query&titles=File:Test_image.png&prop=imageinfo&iiprop=sha1|url&format=json" | jq '.query.pages[].title'

	# Get image url, get sha1 according to database (via API)
	img_url=$( ${docker_exec[@]} curl --insecure -L "$url_base/api.php?action=query&titles=File:Test_image.png&prop=imageinfo&iiprop=sha1|url&format=json" | jq --raw-output '.query.pages[].imageinfo[0].url' )
	img_url=$( echo $img_url | sed 's/https:\/\/[[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+\///' )
	img_url="http://127.0.0.1:8080/$img_url"

	# Retrieve image
	${docker_exec[@]} curl --write-out %{http_code} --silent --output /dev/null "$img_url" \
		| grep -q '200' \
		&& (echo 'Imported image test: pass' && exit 0) \
		|| (echo 'Imported image test: fail' && exit 1)

	# FIXME: TEST FOR IDEMPOTENCE. THIS WILL FAIL CURRENTLY.

else
	echo "Bad test type: $test_type"
	exit 1
fi
