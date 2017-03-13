#!/bin/sh
#
#

# must be root or sudoer
if [ "$(whoami)" != "root" ]; then
	echo "Try running this script with sudo: \"sudo bash import-wiki.sh\""
	exit 1
fi


# If /usr/local/bin is not in PATH then add it
# Ref enterprisemediawiki/meza#68 "Run install.sh with non-root user"
if [[ $PATH != *"/usr/local/bin"* ]]; then
	PATH="/usr/local/bin:$PATH"
fi


#
# For now this script is not called within the same shell as install.sh
# and thus it needs to know how to get to the config.sh script on it's own
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "/opt/meza/config/core/config.sh"


while [ -z "$wiki_id" ]; do
	echo "Please enter the ID of the wiki needing index rebuilding:"
	read wiki_id_test
	if [ ! -z "$wiki_id_test" ] && [ -d "$m_htdocs/wikis/$wiki_id_test" ]; then
		wiki_id="$wiki_id_test"
	fi
done

echo "Rebuilding index for $wiki_id"

source "$m_scripts/elastic-build-index.sh"
