#!/bin/bash
#
#

# Set defaults before declaring now undefined variables
if [ -z "$docker_repo" ]; then
	docker_repo="jamesmontalvo3/meza-docker-test-max:latest"
	echo "Using default docker_repo = $docker_repo"
fi
if [ -z "$init" ]; then
	init="/usr/lib/systemd/systemd"
	echo "Using default init = $init"
fi
if [ -z "$run_opts" ]; then
	run_opts="--privileged --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro"
	echo "Using default run_opts = $run_opts"
fi

# -e: kill script if anything fails
# -u: don't allow undefined variables
# -x: debug mode; print executed commands
set -eux

# Pull the docker image if not already present
if [[ "$(docker images -q $docker_repo 2> /dev/null)" == "" ]]; then
	echo "pulling image $docker_repo"
	docker pull ${docker_repo}
fi

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

	${docker_exec[@]} bash /opt/meza/tests/travis/monolith-from-scratch.sh "$docker_ip"

elif [ "$test_type" == "monolith_from_import" ]; then

	# TEST ANSIBLE SYNTAX. FIXME: syntax check all playbooks
	${docker_exec[@]} ANSIBLE_CONFIG=/opt/meza/config/core/ansible.cfg ansible-playbook /opt/meza/src/playbooks/site.yml --syntax-check

	${docker_exec[@]} bash /opt/meza/tests/travis/monolith-from-import.sh "$docker_ip"

else
	echo "Bad test type: $test_type"
	exit 1
fi
