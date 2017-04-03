#!/bin/sh
#
# Test monolith from preinstall

# -e: kill script if anything fails
# -u: don't allow undefined variables
# -x: debug mode; print executed commands
set -eux

echo "RUNNING TEST monolith-from-preinstall"

fqdn="$1"

sed -r -i 's/docker_skip_tasks: true//g;' "/opt/meza/config/local-secret/monolith/group_vars/all.yml"
sed -r -i "s/INSERT_FQDN/$fqdn/g;" "/opt/meza/config/local-secret/monolith/hosts"

# FIXME: Need to git-fetch and git-checkout the appropriate commit

# Now that environment monolith is setup, deploy/install it
meza deploy monolith

# Need to sleep 10 seconds to let Parsoid finish loading
sleep 10s

# TEST BASIC SYSTEM FUNCTIONALITY
bash /opt/meza/tests/travis/server-check.sh

# Demo Wiki API test
bash /opt/meza/tests/travis/wiki-check.sh "demo" "Demo Wiki"

# CREATE WIKI AND TEST
meza create wiki-promptless monolith created "Created Wiki"

# Created Wiki API test
bash /opt/meza/tests/travis/wiki-check.sh "created" "Created Wiki"

meza backup monolith

ls /opt/meza/data/backups/monolith/demo

# find any files matching *_wiki.sql in demo backups. egrep command will
# exit-0 if something found, exit-1 (fail) if nothing found.
find /opt/meza/data/backups/monolith/demo -name "*_wiki.sql" | egrep '.*'
