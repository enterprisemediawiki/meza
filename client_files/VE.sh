

cd ~/sources

# Download, compile, and install node
wget https://nodejs.org/dist/v0.12.5/node-v0.12.5.tar.gz
tar zxvf node-v0.12.5.tar.gz
cd node-v0.12.5
./configure --prefix=/etc/mediawiki/node
make
make install

# Download and install parsoid
cd /etc/mediawiki
git clone https://gerrit.wikimedia.org/r/p/mediawiki/services/parsoid
cd parsoid
npm install
# npm install results in "npm WARN prefer global jshint@2.8.0 should be installed with -g"

npm test #optional?
# several warnings come out of npm test

# Configure parsoid for wiki use
# This part can be modified once localsettings.js is included in initial download of files
# TODO change client_files to master once merged
# localsettings for parsoid
cd ~/sources/meza1/client_files
wget https://raw.githubusercontent.com/enterprisemediawiki/Meza1/installVE/client_files/localsettings.js
cp localsettings.js /etc/mediawiki/parsoid/api/localsettings.js
# Add VE and UniversalLanguageSelector to ExtensionSettings
wget https://raw.githubusercontent.com/enterprisemediawiki/Meza1/installVE/client_files/ExtensionSettingsVE.php
cp ExtensionSettingsVE.php /var/www/meza1/htdocs/wiki/ExtensionSettingsVE.php
cat /var/www/meza1/htdocs/wiki/ExtensionSettingsVE.php >> /var/www/meza1/htdocs/wiki/ExtensionSettings.php
# Add VE settings to LocalSettings.php
wget https://raw.githubusercontent.com/enterprisemediawiki/Meza1/installVE/client_files/LocalSettingsVE.php
cp LocalSettingsVE.php /var/www/meza1/htdocs/wiki/LocalSettingsVE.php
cat /var/www/meza1/htdocs/wiki/LocalSettingsVE.php >> /var/www/meza1/htdocs/wiki/LocalSettings.php

# Run updateExtensions to install UniversalLanguageSelector and VisualEditor
php /var/www/meza1/htdocs/wiki/extensions/ExtensionLoader/updateExtensions.php

cd /usr/var/meza1/htdocs/wiki/extensions/VisualEditor
# Will this git command work with the way ExtensionLoader installs the extension?
git submodule update --init


# Read https://www.mediawiki.org/wiki/Extension:VisualEditor#Linking_with_Parsoid_in_private_wikis

# Start the server
node ~/sources/parsoid/api/server.js

# Note that you can't access the parsoid service via 192.168.56.58:8000 from host (at least by default)
# but you can use curl 127.0.0.1:8000 in ssh to verify it works

# Need to replace or add an automated way of starting the server (upon reboot)
# https://www.mediawiki.org/wiki/Parsoid/Developer_Setup#Starting_the_Parsoid_service_automatically

# Note documentation for multi-language support configuration: https://www.mediawiki.org/wiki/Extension:UniversalLanguageSelector

# Note: Other extensions which load plugins for VE (e.g. Math) should be loaded after VE for those plugins to work.
