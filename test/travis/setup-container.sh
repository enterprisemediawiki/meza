#!/bin/bash
#
# Sets up a single Docker container


# Run container in detached state, capture container ID
container_id=$(mktemp)
docker run --detach --volume="${PWD}":/opt/meza \
	--add-host="localhost:127.0.0.1" ${run_opts} \
	geerlingguy/docker-${distro}-ansible:latest "${init}" > "${container_id}"
container_id=$(cat ${container_id})

source "$(dirname $0)/variables.sh"

# Get IP of docker image
docker_ip=$(docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" "$container_id")
