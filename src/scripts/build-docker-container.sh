#!/bin/bash
#
# Script to setup meza in a docker container

docker_repo="$1"

if [[ "$(docker images -q $docker_repo 2> /dev/null)" == "" ]]; then
	echo "pulling image $docker_repo"
	docker pull ${docker_repo}
fi


init=/usr/lib/systemd/systemd
run_opts="--privileged --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro"


container_id=$(mktemp)
docker run --detach --volume=/opt/meza:/opt/meza \
	--add-host="localhost:127.0.0.1" ${run_opts} \
	"${docker_repo}" "${init}" > "${container_id}"
container_id=$(cat ${container_id})

# Wrap all the `docker exec ...` in an array for clarity
docker_exec_lite=( docker exec "$container_id" )
docker_exec=( docker exec --tty "$container_id" env TERM=xterm )

# Capture args for cURLing for status codes
curl_args=( curl --write-out %{http_code} --silent --output /dev/null )

${docker_exec[@]} bash /opt/meza/src/scripts/getmeza.sh

${docker_exec[@]} mv /opt/mediawiki /opt/meza/htdocs/mediawiki || true

# Get IP of docker image
docker_ip=$(docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" "$container_id")

${docker_exec[@]} meza setup env monolith --fqdn="${docker_ip}" --db_pass=1234 --enable_email=false --private_net_zone=public

# Now that environment monolith is setup, deploy/install it
${docker_exec[@]} meza deploy monolith

echo "Container setup with id ="
echo "$container_id"
