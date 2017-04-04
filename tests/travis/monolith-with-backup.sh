#!/bin/sh
#
# Script creates two containers:
#   1) A meza monolith, from a pre-built meza docker image
#   2) A backup server, from a base docker image
#
# To call this outside of Travis, you must supply at a minimum as environment
# variables:
#   1) m_meza_host=/opt/meza
#   2) env_name=somename
#   3) TRAVIS_EVENT_TYPE=push
#   4) TRAVIS_COMMIT= a sha1 hash for a commit or a branch like origin/fix123


# -e: kill script if anything fails
# -u: don't allow undefined variables
# -x: debug mode; print executed commands
set -eux

# Initiate CONTAINER 1
docker_repo="jamesmontalvo3/meza-docker-full:latest"
source "$m_meza_host/tests/travis/init-container.sh" "none"
container_id_1="$container_id"
docker_ip_1="$docker_ip"
docker_exec_1=( "${docker_exec[@]}" )


# CONTAINER 1 is controller and monolith
# Copy SSH public key from user "meza-ansible" to host
docker cp "$container_id_1:/home/meza-ansible/.ssh/id_rsa.pub" /tmp/controller.id_rsa.pub

# Turn off host key checking for user meza-ansible, to avoid prompts
${docker_exec_1[@]} bash -c 'echo -e "Host *\n   StrictHostKeyChecking no\n   UserKnownHostsFile=/dev/null" > /home/meza-ansible/.ssh/config'

# CONTAINER 2 is a backup server
source "$m_meza_host/tests/travis/init-minion.sh"
docker_ip_2="$docker_ip"


# Checkout the correct version of meza on the container
# What's present on the pre-built container is not the latest
${docker_exec_1[@]} bash /opt/meza/tests/travis/git-setup.sh "$TRAVIS_EVENT_TYPE" \
	"$TRAVIS_COMMIT" "$TRAVIS_PULL_REQUEST_SHA" "$TRAVIS_BRANCH" "$TRAVIS_PULL_REQUEST_BRANCH"


# Remove existing config info
${docker_exec_1[@]} rm -rf /opt/meza/config/local-secret/monolith
${docker_exec_1[@]} rm -rf /opt/meza/config/local-public

# create a new environment called "travis"
${docker_exec_1[@]} default_servers="localhost" backup_servers="$docker_ip_2" \
	meza setup env "$env_name" \
	--fqdn="$docker_ip_1" --db_pass=1234 --enable_email=false --private_net_zone=public


${docker_exec_1[@]} bash /opt/meza/tests/travis/create-and-backup.sh "$env_name"
