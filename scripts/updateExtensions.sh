#!/bin/sh
#
# Run updateExtensions.php and update.php on all wikis


if [ "$(whoami)" != "root" ]; then
	echo "Try running this script with sudo: \"sudo bash install.sh\""
	exit 1
fi

# If /usr/local/bin is not in PATH then add it
# Ref enterprisemediawiki/meza#68 "Run install.sh with non-root user"
if [[ $PATH != *"/usr/local/bin"* ]]; then
	PATH="/usr/local/bin:$PATH"
fi

source /opt/meza/config/core/config.sh

timestamp=$( date +"%Y%m%d%H%M%S" )
skiplog="$m_meza/logs/skiplog$timestamp"

echo "Using skiplog $skiplog"

cd "$m_htdocs/wikis"
for d in */ ; do

	# trim trailing slash from directory name
	# ref: http://stackoverflow.com/questions/1848415/remove-slash-from-the-end-of-a-variable
	# ref: http://www.network-theory.co.uk/docs/bashref/ShellParameterExpansion.html
	wiki_id=${d%/}

	echo "Starting $wiki_id"

	echo "Running ExtensionLoader updateExtensions.php for $wiki_id"
	php "WIKI=$wiki_id" "$m_mediawiki/extensions/ExtensionLoader/updateExtensions.php" --skip-log="$skiplog"

	echo "Running MediaWiki update.php for $wikiId"
	php "WIKI=$wiki_id" "$m_mediawiki/maintenance/update.php" --quick

done

echo
echo "Complete updating extensions for all wikis"
