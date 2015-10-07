#!/bin/bash
#
# This script is a wrapper on `import-wikis.sh`. By setting the $imports_dir
# variable it overrides the import script's mechanism for finding the source for
# new wikis and instead installs a new wiki.


# must be root or sudoer
if [ "$(whoami)" != "root" ]; then
	echo "Try running this script with sudo: \"sudo bash import-wiki.sh\""
	exit 1
fi


# If /usr/local/bin is not in PATH then add it
# Ref enterprisemediawiki/Meza1#68 "Run install.sh with non-root user"
if [[ $PATH != *"/usr/local/bin"* ]]; then
	PATH="/usr/local/bin:$PATH"
fi


#
# For now this script is not called within the same shell as install.sh
# and thus it needs to know how to get to the config.sh script on it's own
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR/config.sh"


# Set $imports_dir to "new", so import-wikis.sh won't attempt to import existing wikis
imports_dir="new"

# Run import script
source "$DIR/import-wikis.sh"
