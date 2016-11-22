#!/bin/bash
#
# Install MediaWiki extensions.
#

print_title "Starting script extensions.sh"


#
# Since SMW is not installed yet, we need to temporarily remove
# the enableSemantics() function in LocalSettings.php
#
sed -r -i 's/^enableSemantics/\/\/enableSemantics/;' "$m_config/core/LocalSettings.php"


#
# Install Demo MW: create wiki directory, setup basic settings, create database
#
echo -e "\n\nCreating new wiki called \"Demo Wiki\""
imports_dir="new"
wiki_id="demo"
wiki_name="Demo Wiki"
temp_slack="$slackwebhook" # don't notify when Demo Wiki is created.
slackwebhook="n"
source "$m_meza/scripts/create-wiki.sh"
slackwebhook="$temp_slack"

# Clone ExtensionLoader
echo -e "\n\n## meza: Install ExtensionLoader and apply changes to MW settings"
cd "$m_mediawiki/extensions"
git clone https://github.com/jamesmontalvo3/ExtensionLoader.git
cd ./ExtensionLoader
git checkout tags/v0.3.0
cd "$m_mediawiki"


# Install extensions
echo -e "\n\n## meza: update/install extensions"
cmd_profile "START extension loader install"
WIKI=demo php extensions/ExtensionLoader/updateExtensions.php
cmd_profile "END extension loader install"


echo "******* Installing VE *******"
cd "$m_mediawiki/extensions/VisualEditor"
git submodule update --init


# Install Elastica library via composer
cd "$m_mediawiki/extensions/Elastica"
composer install


# Install SyntaxHighlight dependencies
cd "$m_mediawiki/extensions/SyntaxHighlight_GeSHi"
composer install


# Install extensions installed via Composer
echo -e "\n\n## meza: Install composer-supported extensions"
cd "$m_mediawiki"
cmd_profile "START extensions composer require"
composer require \
	mediawiki/semantic-media-wiki:~2.4 \
	mediawiki/semantic-result-formats:~2.0 \
	mediawiki/sub-page-list:~1.1 \
	mediawiki/semantic-meeting-minutes:~0.3 \
	mediawiki/semantic-maps:~3.2
cmd_profile "END extensions composer require"


# Now do enableSemantics()...uncomment function
sed -r -i 's/^\/\/enableSemantics/enableSemantics/;' "$m_config/core/LocalSettings.php"


# update database
cd "$m_mediawiki"
WIKI=demo php maintenance/update.php --quick


# Import pages required for SemanticMeetingMinutes and rebuild indices
echo -e "\n\n## meza: import pages for SemanticMeetingMinutes"
WIKI=demo php maintenance/importDump.php --report --debug < ./extensions/SemanticMeetingMinutes/ImportFiles/import.xml
echo -e "\n\n## meza: rebuildrecentchanges.php"
WIKI=demo php maintenance/rebuildrecentchanges.php
echo -e "\n\n## meza: Extension:TitleKey rebuildTitleKeys.php"
WIKI=demo php extensions/TitleKey/rebuildTitleKeys.php

#
# Create "Admin" user on Demo Wiki
# This is sort of strange in this location, but it cannot be done much prior to
# this due to the fact that everything defined in our pre-built LocalSettings.php
# must be available prior to running any maintenance scripts. Thus, it must be
# after SMW install due to the `enableSemantics()` function in LocalSettings.php.
# Other extensions could cause similar issues, so it's best that this go after
# loading extensions.
#
WIKI=demo php "$m_meza/scripts/mezaCreateUser.php" --username=Admin --password=1234 --groups=sysop,bureaucrat

#
# Generate ES index, since it is skipped in the initial create-wiki.sh
#
# Ref: https://git.wikimedia.org/blob/mediawiki%2Fextensions%2FCirrusSearch.git/REL1_25/README
#
#
echo "******* Running elastic-build-index.sh *******"
wiki_id=demo
source "$m_meza/scripts/elastic-build-index.sh"


# NOTE: I think this can be in LocalSettings.php to start. Don't think it needs to be added later.
# Add "$wgSearchType = 'CirrusSearch';" to LocalSettings.php to funnel queries to ElasticSearch

