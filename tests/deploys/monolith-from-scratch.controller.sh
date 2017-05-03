#!/bin/sh
#
# Test monolith from scratch

# -e: kill script if anything fails
# -u: don't allow undefined variables
# -x: debug mode; print executed commands
set -eux

echo "RUNNING TEST monolith-from-scratch"

fqdn="$1"

# Since we want to make the monolith environment without prompts, need to do
# `meza setup env monolith` with values for required args included (fqdn,
# db_pass, email, private_net_zone).
meza setup env monolith --fqdn="${fqdn}" --db_pass=1234 --enable_email=false --private_net_zone=public

echo "print hosts file"
cat /opt/conf-meza/secret/monolith/hosts

# Now that environment monolith is setup, deploy/install it
meza deploy monolith

# Need to sleep 10 seconds to let Parsoid finish loading
sleep 10s

# TEST BASIC SYSTEM FUNCTIONALITY
bash /opt/meza/tests/integration/server-check.sh

# Demo Wiki API test
bash /opt/meza/tests/integration/wiki-check.sh "demo" "Demo Wiki"
