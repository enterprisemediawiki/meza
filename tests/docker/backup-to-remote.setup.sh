#!/bin/sh
#
# Script creates two containers:
#   1) A meza monolith, from a pre-built meza docker image
#   2) A backup server, from a base docker image
#
# To run this you must supply at a minimum these env variables:
#   1) m_meza_host=/opt/meza
#   2) env_name=somename
#   3) I think: container_id, docker_ip, docker_exec


# -e: kill script if anything fails
# -u: don't allow undefined variables
# -x: debug mode; print executed commands
set -eux


# CONTAINER 1 is controller and monolith
source "$m_meza_host/tests/docker/init-controller.sh"
container_id_1="$container_id"
docker_ip_1="$docker_ip"
docker_exec_1=( "${docker_exec[@]}" )


# CONTAINER 2 is a backup server
source "$m_meza_host/tests/docker/init-minion.sh"
docker_ip_2="$docker_ip"
docker_exec_2=( "${docker_exec[@]}" )


# Create a new environment called "travis" with everything on CONTAINER 1, but
# backups on CONTAINER 2
${docker_exec_1[@]} default_servers="$docker_ip_1" backup_servers="$docker_ip_2" \
	meza setup env "$env_name" \
	--fqdn="$docker_ip_1" --db_pass=1234 --private_net_zone=public


public_yml="/opt/conf-meza/public/public.yml"
${docker_exec_1[@]} bash -c "mkdir -p /opt/conf-meza/public"
${docker_exec_1[@]} bash -c "echo -e '---\n' > $public_yml"
${docker_exec_1[@]} bash -c "echo -e 'sshd_config_UsePAM: \"no\"\n' >> $public_yml"
${docker_exec_1[@]} bash -c "echo -e 'sshd_config_PasswordAuthentication: \"yes\"\n' >> $public_yml"


# secret.yml is encrypted. decrypt first, make edits, re-encrypt.
# secret_yml="/opt/conf-meza/secret/$env_name/secret.yml"
# vault_pass="/opt/conf-meza/vault/vault-pass-$env_name.txt"
# ${docker_exec_1[@]} bash -c "ansible-vault decrypt $secret_yml --vault-password-file $vault_pass"
# ${docker_exec_1[@]} bash -c "echo -e '\n' >> $secret_yml"
# ${docker_exec_1[@]} bash -c "echo 'mysql_root_password_update: yes' >> $secret_yml"
# ${docker_exec_1[@]} bash -c "echo -e '\n' >> $secret_yml"
# ${docker_exec_1[@]} bash -c "ansible-vault encrypt $secret_yml --vault-password-file $vault_pass"


# Run script on controller to `meza deploy`, `meza create wiki` and
# `meza backup`
${docker_exec_1[@]} bash /opt/meza/tests/deploys/backup-to-remote.controller.sh "$env_name"


# RUN TESTS ON CONTAINER 2
#
# The following are two checks against CONTAINER 2 to verify backup was
# performed correctly.
#
# (1) Verify backups directory exists
# (2) Verify any files matching *_wiki.sql in demo backups. egrep command will
#     exit-0 if something found, exit-1 (fail) if nothing found.
${docker_exec_2[@]} ls "/opt/data-meza/backups/$env_name/demo"
${docker_exec_2[@]} find "/opt/data-meza/backups/$env_name/demo" -name "*_wiki.sql" | egrep '.*'
