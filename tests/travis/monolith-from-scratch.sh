#!/bin/sh
#
# Test monolith from scratch

# -e: kill script if anything fails
# -u: don't allow undefined variables
# -x: debug mode; print executed commands
set -eux

fqdn="$1"

# Since we want to make the monolith environment without prompts, need to do
# `meza setup env monolith` with values for required args included (fqdn,
# db_pass, email, private_net_zone).
meza setup env monolith --fqdn="${fqdn}" --db_pass=1234 --enable_email=false --private_net_zone=public

# Now that environment monolith is setup, deploy/install it
meza deploy monolith

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
