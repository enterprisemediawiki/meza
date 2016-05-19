#!/bin/sh
#
# Run testssl.sh, setup if required.

testssldir="/opt/meza/sources/testssl.sh"
testsslcmd="$testssldir/testssl.sh"

if [ ! -d "$testssldir" ]; then
        git clone https://github.com/drwetter/testssl.sh.git "$testssldir"
fi

$testsslcmd -U https://localhost
