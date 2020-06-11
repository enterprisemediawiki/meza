#!/bin/sh
#
# Get a container ready to be a controller


# Initiate container
docker_repo="enterprisemediawiki/meza:full"
source "$m_meza_host/tests/docker/init-container.sh" "${m_meza_host}" "mount"

# FIXME #728: Test band-aid. This is run in init-container.sh above, but at
# that time the meza version is whatever is on the Docker container (possibly
# very old). After checking out the correct version via git above, re-run
# getmeza.sh, which moves /home/meza-ansible to /opt/conf-meza/users/meza-ansible
# Note: Connection check fails on GitHub Actions
${docker_exec[@]} bash /opt/meza/src/scripts/getmeza.sh --skip-conn-check


# Turn off host key checking for user meza-ansible, to avoid prompts
${docker_exec[@]} bash -c 'echo -e "Host *\n   StrictHostKeyChecking no\n   UserKnownHostsFile=/dev/null" > /opt/conf-meza/users/meza-ansible/.ssh/config'


# Allow SSH login, in case this server SSHs into itself
# WARNING: This is INSECURE and for test environment only
${docker_exec[@]} sed -r -i 's/UsePAM yes/UsePAM no/g;' /etc/ssh/sshd_config
${docker_exec[@]} systemctl restart sshd


# Copy SSH public key from user "meza-ansible" to host
# This will allow putting the key onto minion servers
docker cp "$container_id:/opt/conf-meza/users/meza-ansible/.ssh/id_rsa.pub" /tmp/controller.id_rsa.pub


# Remove existing config info
${docker_exec[@]} rm -rf /opt/conf-meza/secret/monolith || true
${docker_exec[@]} rm -rf /opt/conf-meza/public || true

# Docker image has these pre-installed with Composer, which conflicts with
# attempts to install them with Git. Remove SMM from composer.local.json then
# run composer update.
# FIXME #728: Update the Docker image to have these preinstalled with Git (not
# Composer), then remove these lines.
${docker_exec[@]} sed -i '/semantic-meeting-minutes/d' /opt/htdocs/mediawiki/composer.local.json || true
${docker_exec[@]} bash -c 'cd /opt/htdocs/mediawiki && /usr/local/bin/composer update'
${docker_exec[@]} ls -la /opt/htdocs/mediawiki/extensions
