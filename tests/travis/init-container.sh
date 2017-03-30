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

# If $host_mount_dir is defined, mount that dir as /opt/meza on the container.
# If not, mount nothing. $meza_version must then be supplied, to git-clone that
# version further down in this script
if [ -z "$host_mount_dir" ]; then
	docker_mount=""
else
	docker_mount="--volume=${host_mount_dir}:/opt/meza"
fi

# -e: kill script if anything fails
# -u: don't allow undefined variables
# -x: debug mode; print executed commands
set -eux

# Print git version that will be checked out. Since the -u option is set above,
# this will cause an error if $meza_version is missing.
if [ "$docker_mount" = "" ]; then
	echo "Not mounting /opt/meza from host. Will git-clone meza version $meza_version"
fi

# Pull the docker image if not already present
if [[ "$(docker images -q $docker_repo 2> /dev/null)" == "" ]]; then
	echo "pulling image $docker_repo"
	docker pull ${docker_repo}
fi


# SETUP CONTAINER
# Run container in detached state, capture container ID
container_id=$(mktemp)
docker run --detach "$meza_mount" \
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

# Docker image "jamesmontalvo3/meza-docker-test-max:latest" has mediawiki and
# several extensions pre-cloned, but not in the correct location. Move them
# into place. For some reason gives exit code 129 on Travis sometimes. Force
# non-failing exit code.
${docker_exec[@]} mv /opt/mediawiki /opt/meza/htdocs/mediawiki || true

# If meza repo not mounted from host, clone it
if [ "$docker_mount" = "" ]; then
	${docker_exec[@]} git clone https://github.com/enterprisemediawiki/meza /opt/meza
	${docker_exec[@]} git --git-dir=/opt/meza/.git checkout "$meza_version"
fi

# Install meza command
${docker_exec[@]} bash /opt/meza/src/scripts/getmeza.sh
