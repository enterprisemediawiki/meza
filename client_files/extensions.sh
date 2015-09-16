#!/bin/bash
#
# Install MediaWiki extensions.
#

print_title "Starting script extensions.sh"


# Clone ExtensionLoader
echo -e "\n\n## Meza1: Install ExtensionLoader and apply changes to MW settings"
cd "$m_mediawiki/extensions"
git clone https://github.com/jamesmontalvo3/ExtensionLoader.git
cd ..


# Add ExtensionSettings.php (used by ExtensionLoader) from Meza1 repo
cp "$m_meza/client_files/ExtensionSettings.php" ./ExtensionSettings.php


# Install extensions and update database
echo -e "\n\n## Meza1: update/install extensions"
cmd_profile "START extension loader install"
WIKI=demo php extensions/ExtensionLoader/updateExtensions.php
cmd_profile "END extension loader install"


# Install extensions installed via Composer
echo -e "\n\n## Meza1: Install composer-supported extensions"
cmd_profile "START extensions composer require"
composer require \
	mediawiki/semantic-media-wiki:~2.0 \
	mediawiki/semantic-result-formats:~2.0 \
	mediawiki/sub-page-list:~1.1 \
	mediawiki/semantic-meeting-minutes:~0.3
cmd_profile "END extensions composer require"


echo "******* Installing VE *******"
cd "$m_mediawiki/extensions/VisualEditor"
git submodule update --init


# Install Elastica library via composer
cd "$m_mediawiki/extensions/Elastica"
composer install


#
# Install Demo MW: create wiki directory, setup basic settings, create database
#
imports_dir="new"
wiki_id="demo"
wiki_name="Demo Wiki"
source "$m_meza/client_files/create-wiki.sh"
# note: now update.php required since it's in create-wiki.sh (import-wiki.sh, more specifically)

# update database
cd "$m_mediawiki"

# Import pages required for SemanticMeetingMinutes and rebuild indices
echo -e "\n\n## Meza1: import pages for SemanticMeetingMinutes"
WIKI=demo php maintenance/importDump.php < ./extensions/SemanticMeetingMinutes/ImportFiles/import.xml
echo -e "\n\n## Meza1: rebuildrecentchanges.php"
WIKI=demo php maintenance/rebuildrecentchanges.php
echo -e "\n\n## Meza1: Extension:TitleKey rebuildTitleKeys.php"
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
cp "$m_meza/client_files/mezaCreateUser.php" /var/www/meza1/mezaCreateUser.php
WIKI=demo php /var/www/meza1/mezaCreateUser.php --username=Admin --password=1234 --groups=sysop,bureaucrat

#
# Generate ES index
#
# Ref: https://git.wikimedia.org/blob/mediawiki%2Fextensions%2FCirrusSearch.git/REL1_25/README
#
echo "******* Running elastic-build-index.sh *******"
wiki_id=demo
# @todo @fixme Does this need to run here, or is it sufficient during create-wiki.sh?
source "$m_meza/client_files/elastic-build-index.sh"


# NOTE: I think this can be in LocalSettings.php to start. Don't think it needs to be added later.
# Add "$wgSearchType = 'CirrusSearch';" to LocalSettings.php to funnel queries to ElasticSearch

