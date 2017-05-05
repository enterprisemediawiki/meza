#!/bin/sh
#
# monolith from import

# -e: kill script if anything fails
# -u: don't allow undefined variables
# -x: debug mode; print executed commands
set -eux

echo "RUNNING TEST monolith-from-import"

fqdn="$1"

env_name="imported"

# Get test "secret" config, make meza-ansible own it
git clone https://github.com/enterprisemediawiki/meza-test-config-secret.git "/opt/conf-meza/secret/$env_name"

# Write the docker containers IP as the FQDN for the test config (the only
# config setting we can't know ahead of time)
sed -r -i "s/INSERT_FQDN/$fqdn/g;" "/opt/conf-meza/secret/$env_name/group_vars/all.yml"

# get backup files
git clone https://github.com/jamesmontalvo3/meza-test-backups.git "/opt/data-meza/backups/$env_name"

# Deploy environment with test config
meza deploy "$env_name"

# Need to wait after install before checking that Parsoid is working
sleep 10s

# Basic system check
bash /opt/meza/tests/integration/server-check.sh

# Several wiki checks
bash /opt/meza/tests/integration/wiki-check.sh "top" "Top Wiki"

# Test for imported image
bash /opt/meza/tests/integration/image-check.sh "top" "Test_image.png"
