#!/bin/bash
#
#

# Allow undefined vars just for this top part
set +u

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

host_meza_dir="$1"
host_meza_dir_method="$2"

if [ -z "$host_meza_dir" ]; then
	echo "host_meza_dir not set"
	exit 1
elif [ "$host_meza_dir" = "none" ]; then
	host_meza_dir_method="none"
elif [ ! -d "$host_meza_dir" ]; then
	echo "$host_meza_dir is not a valid directory (for host_meza_dir)"
	exit 1
fi

if [ "$host_meza_dir_method" = "mount" ]; then
	docker_volume="--volume=${host_meza_dir}:/opt/meza"
elif [ "$host_meza_dir_method" = "none" ]; then
	docker_volume=""
else
	docker_volume=""
	host_meza_dir_method="copy"
fi

if [ -z "$is_minion" ] || [ "$is_minion" == "no" ]; then
	is_minion=no
else
	is_minion=yes
fi

if [ ! -z "$container_name" ]; then
	set_container_name="--name $container_name"
else
	set_container_name=""
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


# SETUP CONTAINER
# Run container in detached state, capture container ID
container_id=$(mktemp)
docker run --detach $docker_volume "$set_container_name" \
	--add-host="localhost:127.0.0.1" ${run_opts} \
	"${docker_repo}" "${init}" > "${container_id}"
container_id=$(cat ${container_id})

# Wrap all the `docker exec ...` in an array for clarity
docker_exec=( docker exec --tty "$container_id" env TERM=xterm )

# Make sure firewalld installed and docker0 interface is in zone public
# Discovered thanks to https://github.com/docker/docker/issues/16137
# Note this was only observed on Docker on Travis CI, not on Docker on a CentOS
# or Ubuntu 14.04 host. Only tested on new version of Docker (docker-ce version
# 17.something), whereas Travis is on 1.12.something.
${docker_exec[@]} yum -y install firewalld
${docker_exec[@]} systemctl start firewalld
${docker_exec[@]} firewall-cmd --permanent --zone=public --change-interface=docker0

if [ "$is_minion" == "no" ]; then

	# Docker image "jamesmontalvo3/meza-docker-test-max:latest" has mediawiki and
	# several extensions pre-cloned, but not in the correct location. Move them
	# into place. For some reason gives exit code 129 on Travis sometimes. Force
	# non-failing exit code.
	${docker_exec[@]} mv /opt/mediawiki /opt/meza/htdocs/mediawiki || true

	# If not mounting the host's meza directory, copy it to the container
	if [ "$host_meza_dir_method" = "copy" ]; then
		docker cp "$host_meza_dir" "$container_id:/opt/meza"
	fi

	# Install meza command
	${docker_exec[@]} bash /opt/meza/src/scripts/getmeza.sh

fi
# reset to no, in case follow on builds don't reset
is_minion=no

# Get IP of docker image
docker_ip=$(docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" "$container_id")
