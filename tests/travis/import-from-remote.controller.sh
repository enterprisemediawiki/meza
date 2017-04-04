#!/bin/sh
#
# monolith from import

# -e: kill script if anything fails
# -u: don't allow undefined variables
# -x: debug mode; print executed commands
set -eux

echo "RUNNING TEST"

# Deploy environment with test config
meza deploy "$1" -vvvv

# Need to wait after install before checking that Parsoid is working
sleep 10s

# Basic system check
bash /opt/meza/tests/travis/server-check.sh

# Several wiki checks
bash /opt/meza/tests/travis/wiki-check.sh "top" "Top Wiki"

# Test for imported image
bash /opt/meza/tests/travis/image-check.sh "top" "Test_image.png"
