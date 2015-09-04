#!/bin/bash
#
# Install MediaWiki extensions.
#

print_title "Starting script extensions.sh"

cd "$m_mediawiki"

# Install extensions installed via Composer
echo -e "\n\n## Meza1: Install composer-supported extensions"
cmd_profile "START extensions composer require"
composer require \
	mediawiki/semantic-media-wiki:~2.0 \
	mediawiki/semantic-result-formats:~2.0 \
	mediawiki/sub-page-list:~1.1 \
	mediawiki/semantic-meeting-minutes:~0.3
cmd_profile "END extensions composer require"

# SMW, and perhaps others just installed, require DB update after install
echo -e "\n\n## Meza1: update database"
php maintenance/update.php --quick

# Clone ExtensionLoader
echo -e "\n\n## Meza1: Install ExtensionLoader and apply changes to MW settings"
cd extensions
git clone https://github.com/jamesmontalvo3/ExtensionLoader.git
cd ..

# Add settings to LocalSettings.php from Meza1 repo
cat "$m_meza/client_files/LocalSettingsAdditions" >> ./LocalSettings.php

# Add ExtensionLoader setup to LocalSettings.php
cat ./extensions/ExtensionLoader/LocalSettings-append >> ./LocalSettings.php

# Add ExtensionSettings.php (used by ExtensionLoader) from Meza1 repo
cp "$m_meza/client_files/ExtensionSettings.php" ./ExtensionSettings.php

# Install extensions and update database
echo -e "\n\n## Meza1: update/install extensions"
cmd_profile "START extension loader install"
php extensions/ExtensionLoader/updateExtensions.php
cmd_profile "END extension loader install"
php maintenance/update.php --quick

# Import pages required for SemanticMeetingMinutes and rebuild indices
echo -e "\n\n## Meza1: import pages for SemanticMeetingMinutes"
php maintenance/importDump.php < ./extensions/SemanticMeetingMinutes/ImportFiles/import.xml
echo -e "\n\n## Meza1: rebuildrecentchanges.php"
php maintenance/rebuildrecentchanges.php
echo -e "\n\n## Meza1: Extension:TitleKey rebuildTitleKeys.php"
php extensions/TitleKey/rebuildTitleKeys.php

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
