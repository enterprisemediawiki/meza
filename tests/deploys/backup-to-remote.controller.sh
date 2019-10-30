#!/bin/sh
#
# Test monolith from preinstall

# -e: kill script if anything fails
# -u: don't allow undefined variables
# -x: debug mode; print executed commands
set -eux

echo "RUNNING TEST"

# Skip firewalld tasks since they broke in Travis (Issue #1237)
echo -e '\nfirewall_skip_tasks: True\n' >> '/opt/conf-meza/public/public.yml'

# Now that environment is setup, deploy/install it
meza deploy "$1"

# Need to sleep 10 seconds to let Parsoid finish loading
sleep 10s

# TEST BASIC SYSTEM FUNCTIONALITY
bash /opt/meza/tests/integration/server-check.sh

# Demo Wiki API test
bash /opt/meza/tests/integration/wiki-check.sh "demo" "Demo Wiki"

# CREATE WIKI AND TEST
meza create wiki-promptless "$1" created "Created Wiki"

# Created Wiki API test
bash /opt/meza/tests/integration/wiki-check.sh "created" "Created Wiki"

meza backup "$1"
