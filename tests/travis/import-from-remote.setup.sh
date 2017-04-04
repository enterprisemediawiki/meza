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


# CONTAINER 1 is controller and monolith
source "$m_meza_host/tests/travis/init-controller.sh"
container_id_1="$container_id"
docker_ip_1="$docker_ip"
docker_exec_1=( "${docker_exec[@]}" )


# CONTAINER 2 is a backup server
source "$m_meza_host/tests/travis/init-minion.sh"
docker_ip_2="$docker_ip"
docker_exec_2=( "${docker_exec[@]}" )


# CONTAINER 1
# (1) Get local secret config from repo
# (2) Change backup server IP address to docker#2
# (3) Change FQDN IP address to docker#1
${docker_exec_1[@]} git clone \
	https://github.com/enterprisemediawiki/meza-test-config-secret.git \
	"/opt/meza/config/local-secret/$env_name"
${docker_exec_1[@]} sed -r -i "s/localhost #backup/$docker_ip_2/g;" \
	"/opt/meza/config/local-secret/$env_name/hosts"
${docker_exec_1[@]} sed -r -i "s/INSERT_FQDN/$docker_ip_1/g;" \
	"/opt/meza/config/local-secret/$env_name/group_vars/all.yml"


# CONTAINER 2: get backup files
${docker_exec_2[@]} git clone \
	https://github.com/jamesmontalvo3/meza-test-backups.git \
	"/opt/meza/data/backups/$env_name"


# Run script on controller to `meza deploy`, `meza create wiki` and
# `meza backup`
${docker_exec_1[@]} bash /opt/meza/tests/travis/import-from-remote.controller.sh "$env_name"
