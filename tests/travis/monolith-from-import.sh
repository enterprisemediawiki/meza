#!/bin/sh
#
# monolith from import

# -e: kill script if anything fails
# -u: don't allow undefined variables
# -x: debug mode; print executed commands
set -eux

fqdn="$1"

# The may be issues with calling the environment anything other than "monolith"
env_name="monolith"

# Get test "secret" config
# mkdir /opt/meza/config/local-secret
git clone https://github.com/enterprisemediawiki/meza-test-config-secret.git "/opt/meza/config/local-secret/$env_name"

# Write the docker containers IP as the FQDN for the test config (the only
# config setting we can't know ahead of time)
sed -r -i "s/INSERT_FQDN/$fqdn/g;" "/opt/meza/config/local-secret/$env_name/group_vars/all.yml"

# get backup files
git clone https://github.com/jamesmontalvo3/meza-test-backups.git "/opt/meza/data/backups/$env_name"

# Deploy environment with test config
meza deploy "$env_name"

# Basic system check
bash /opt/meza/tests/travis/server-check.sh

# Is Parsoid service running?
curl -L "http://127.0.0.1:8000"

# Top Wiki API test
bash /opt/meza/tests/travis/wiki-check.sh "top" "Top Wiki"

# Test for imported image
bash /opt/meza/tests/travis/image-check.sh "top" "Test_image.png"
