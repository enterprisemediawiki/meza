#!/bin/sh
#
# Get a container ready to be a controller


# Initiate container
docker_repo="jamesmontalvo3/meza-docker-full:latest"
source "$m_meza_host/tests/docker/init-container.sh" "none"


# Copy SSH public key from user "meza-ansible" to host
# This will allow putting the key onto minion servers
docker cp "$container_id:/home/meza-ansible/.ssh/id_rsa.pub" /tmp/controller.id_rsa.pub


# Turn off host key checking for user meza-ansible, to avoid prompts
${docker_exec[@]} bash -c 'echo -e "Host *\n   StrictHostKeyChecking no\n   UserKnownHostsFile=/dev/null" > /home/meza-ansible/.ssh/config'


# Allow SSH login, in case this server SSHs into itself
# WARNING: This is INSECURE and for test environment only
${docker_exec[@]} sed -r -i 's/UsePAM yes/UsePAM no/g;' /etc/ssh/sshd_config
${docker_exec[@]} systemctl restart sshd


# Checkout the correct version of meza on the container
# What's present on the pre-built container is not the latest. Need to pull
# master in case the docker image doesn't have the correct git-setup.sh script
# yet
${docker_exec[@]} bash -c "cd /opt/meza && git fetch origin && git reset --hard origin/master"
${docker_exec[@]} bash /opt/meza/tests/travis/git-setup.sh "$TRAVIS_EVENT_TYPE" \
	"$TRAVIS_COMMIT" "$TRAVIS_PULL_REQUEST_SHA" "$TRAVIS_BRANCH" "$TRAVIS_PULL_REQUEST_BRANCH"


# Remove existing config info
${docker_exec[@]} rm -rf /opt/meza/config/local-secret/monolith || true
${docker_exec[@]} rm -rf /opt/meza/config/local-public || true

# Docker image has these pre-installed with Composer, which conflicts with
# attempts to install them with Git. Remove SMM from composer.local.json then
# run composer update.
# FIXME: Update the Docker image to have these preinstalled with Git (not
# Composer), then remove these lines.
${docker_exec[@]} sed -i '/semantic-meeting-minutes/d' /opt/meza/htdocs/mediawiki/composer.local.json || true
${docker_exec[@]} bash -c 'cd /opt/meza/htdocs/mediawiki && /usr/local/bin/composer update'
${docker_exec[@]} ls -la /opt/meza/htdocs/mediawiki/extensions
