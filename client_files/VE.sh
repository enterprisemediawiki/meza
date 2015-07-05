
echo "******* Downloading node.js *******"
cd ~/sources

# Download, compile, and install node
# Ref: https://www.digitalocean.com/community/tutorials/how-to-install-and-run-a-node-js-app-on-centos-6-4-64bit
wget https://nodejs.org/dist/v0.12.5/node-v0.12.5.tar.gz
tar zxvf node-v0.12.5.tar.gz
cd node-v0.12.5
./configure
echo "******* Compiling node.js *******"
make
echo "******* Installing node.js *******"
make install

# Download and install parsoid
echo "******* Downloading parsoid *******"
cd /etc
git clone https://gerrit.wikimedia.org/r/p/mediawiki/services/parsoid
cd parsoid
echo "******* Installing parsoid *******"
#npm install -g # install globally
#attempt to install globally was resulting in several errors
npm install
# npm install results in "npm WARN prefer global jshint@2.8.0 should be installed with -g"

echo "******* Testing parsoid *******"
npm test #optional?
# several warnings come out of npm test

# Configure parsoid for wiki use
# TODO This part can be modified once localsettings.js is included in initial download of files
# TODO change client_files to master once merged
# localsettings for parsoid
echo "******* Downloading configuration files *******"
cd ~/sources/meza1/client_files

# Copy Parsoid settings from Meza to Parsoid install
cp ./localsettings.js /etc/parsoid/api/localsettings.js
# Add VE and UniversalLanguageSelector to ExtensionSettings
cat ./ExtensionSettingsVE.php >> /var/www/meza1/htdocs/wiki/ExtensionSettings.php
# Add VE settings to LocalSettings.php
cat ./LocalSettingsVE.php >> /var/www/meza1/htdocs/wiki/LocalSettings.php

# Run updateExtensions to install UniversalLanguageSelector and VisualEditor
echo "******* Installing extensions *******"
php /var/www/meza1/htdocs/wiki/extensions/ExtensionLoader/updateExtensions.php

echo "******* Installing VE *******"
cd /var/www/meza1/htdocs/wiki/extensions/VisualEditor
git submodule update --init

# Create parsoid user to run parsoid node server
cd /etc/parsoid # @issue#48: is this necessary?
useradd parsoid

# Grant parsoid user ownership of /opt/services/parsoid
chown parsoid:parsoid /etc/parsoid -R

# I used the following references for an automated service for starting parsoid on boot:
# https://www.mediawiki.org/wiki/Parsoid/Developer_Setup#Starting_the_Parsoid_service_automatically
# http://www.tldp.org/HOWTO/HighQuality-Apps-HOWTO/boot.html
# https://github.com/narath/brigopedia#setup-visualeditor-extension
# Create service script
echo "******* Creating parsoid service *******"
cd ~/sources/meza1/client_files
cp ./initd_parsoid.sh /etc/init.d/parsoid
chmod 755 /etc/init.d/parsoid
chkconfig --add /etc/init.d/parsoid

# Start parsoid service
echo "******* Starting parsoid server *******"
#chkconfig parsoid on # @todo: not required?
service parsoid start
sleep 10  # Waits 10 seconds
echo "******* Please test VE in your wiki *******"

# Note that you can't access the parsoid service via 192.168.56.58:8000 from host (at least by default)
# but you can use curl 127.0.0.1:8000 in ssh to verify it works

# Note documentation for multi-language support configuration: https://www.mediawiki.org/wiki/Extension:UniversalLanguageSelector

# Note: Other extensions which load plugins for VE (e.g. Math) should be loaded after VE for those plugins to work.
