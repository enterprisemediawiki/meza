#!/bin/bash
#
# Install MediaWiki extensions. 
#

cd /var/www/meza1/htdocs/wiki

# Install extensions installed via Composer
echo -e "\n\n## Meza1: Install composer-supported extensions"
php ~/sources/composer.phar require \
	mediawiki/semantic-media-wiki:~2.0 \
	mediawiki/semantic-result-formats:~2.0 \
	mediawiki/sub-page-list:~1.1 \
	mediawiki/semantic-meeting-minutes:~0.3

# SMW, and perhaps others just installed, require DB update after install
echo -e "\n\n## Meza1: update database"
php maintenance/update.php --quick

# Clone ExtensionLoader
echo -e "\n\n## Meza1: Install ExtensionLoader and apply changes to MW settings"
cd extensions
git clone https://github.com/jamesmontalvo3/ExtensionLoader.git
cd ..

# Add settings to LocalSettings.php from Meza1 repo
cat ~/sources/meza1/client_files/LocalSettingsAdditions >> ./LocalSettings.php

# Add ExtensionLoader setup to LocalSettings.php
cat ./extensions/ExtensionLoader/LocalSettings-append >> ./LocalSettings.php

# Add ExtensionSettings.php (used by ExtensionLoader) from Meza1 repo
cp ~/sources/meza1/client_files/ExtensionSettings.php ./ExtensionSettings.php

# Install extensions and update database
echo -e "\n\n## Meza1: update/install extensions"
php extensions/ExtensionLoader/updateExtensions.php
php maintenance/update.php --quick

# Import pages required for SemanticMeetingMinutes and rebuild indices
echo -e "\n\n## Meza1: import pages for SemanticMeetingMinutes"
php maintenance/importDump.php < ./extensions/SemanticMeetingMinutes/ImportFiles/import.xml
echo -e "\n\n## Meza1: rebuildrecentchanges.php"
php maintenance/rebuildrecentchanges.php
echo -e "\n\n## Meza1: Extension:TitleKey rebuildTitleKeys.php"
php extensions/TitleKey/rebuildTitleKeys.php
