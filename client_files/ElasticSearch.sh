#
# This script installs everything required to use elasticsearch in MediaWiki
# 
# Dependencies
# - PHP compiled with cURL
# - Elasticsearch
#   - JAVA 7+
# - Extension:Elastica
# - Extension:CirrusSearch
# 
# Ref:
# https://www.mediawiki.org/wiki/Extension:CirrusSearch
# https://en.wikipedia.org/w/api.php?action=cirrus-config-dump&srbackend=CirrusSearch&format=json
# https://git.wikimedia.org/blob/mediawiki%2Fextensions%2FCirrusSearch.git/REL1_25/README
# https://www.mediawiki.org/wiki/Extension:CirrusSearch/Tour
# https://wikitech.wikimedia.org/wiki/Search
#

#
# Install JAVA
# 
# http://docs.oracle.com/javase/8/docs/technotes/guides/install/linux_jdk.html#BJFJHFDD
# http://stackoverflow.com/questions/10268583/how-to-automate-download-and-installation-of-java-jdk-on-linux
#
echo "******* Downloading and installing JAVA Development Kit *******"
cd ~/sources/meza1/client_files
yum -y install java-1.7.0-openjdk
# Reference this for if we want to try JDK 8: http://tecadmin.net/install-java-8-on-centos-rhel-and-fedora/
## wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jdk-8u45-linux-x64.rpm
## rpm -ivh jdk-8u45-linux-x64.rpm

# Display java version for reference
java -version

# Set $JAVA_HOME
#
# http://askubuntu.com/questions/175514/how-to-set-java-home-for-openjdk
#
echo "export JAVA_HOME=/usr/bin" > /etc/profile.d/java.sh
source /etc/profile.d/java.sh
echo "JAVA_HOME = $JAVA_HOME"

# Install Elasticsearch via yum repository
#
# https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-repositories.html
# 
echo "******* Installing Elasticsearch *******"

# Download and install the public signing key:
cd ~/sources/meza1/client_files
rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch

# Add yum repo file
cp ./elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo

# Install repo
yum -y install elasticsearch

# Configure Elasticsearch to automatically start during bootup
echo "******* Adding Elasticsearch service *******"
chkconfig --add elasticsearch

# *** MANUAL INSTALLATION OPTION (delete) ***
# cd ~/sources
# curl -L -O https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.6.0.tar.gz
# tar -xvf elasticsearch-1.6.0.tar.gz
# cp -r elasticsearch-1.6.0 /etc/elasticsearch-1.6.0
# cd /etc/elasticsearch-1.6.0/bin

#
# Elasticsearch Configuration
#
# https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-configuration.html
# 

echo "******* Adding Elasticsearch configuration *******"
# Add host name per https://github.com/elastic/elasticsearch/issues/6611
echo "127.0.0.1 Meza1" >> /etc/hosts

# Rename the standard config file and copy over our custom config file
cd /etc/elasticsearch
mv ./elasticsearch.yml ./elasticsearch-old.yml
cd ~/sources/meza1/client_files
cp ./elasticsearch.yml /etc/elasticsearch/elasticsearch.yml

# Make directories called out in elasticsearch.yml
# ref: http://elasticsearch-users.115913.n3.nabble.com/Elasticsearch-Not-Working-td4059398.html
cd /var
mkdir data
cd data
mkdir elasticsearch
cd /var
mkdir work
cd work
mkdir elasticsearch
cd /var
# Grant elasticsearch user ownership of these new directories
chown -R elasticsearch /var/data/elasticsearch
chown -R elasticsearch /var/work/elasticsearch

#
# Install Extension:Elastica and Extension:CirrusSearch
#
echo "******* Adding extensions to ExtensionLoader *******"
cd ~/sources/meza1/client_files
# Add Elastica and CirrusSearch to ExtensionSettings
cat /var/www/meza1/htdocs/wiki/ExtensionSettingsElasticSearch.php >> ./ExtensionSettingsElasticSearch.php

#
# MW Configuration
# 

# Add CirrusSearch settings to LocalSettings.php
echo "******* Downloading configuration files *******"
cd ~/sources/meza1/client_files
cat /var/www/meza1/htdocs/wiki/LocalSettingsElasticSearch.php >> ./LocalSettingsElasticSearch.php

# Run updateExtensions to install UniversalLanguageSelector and VisualEditor
echo "******* Installing extensions *******"
php /var/www/meza1/htdocs/wiki/extensions/ExtensionLoader/updateExtensions.php
# Install Elastica library via composer
cd /var/www/meza1/htdocs/wiki/extensions/Elastica
composer install

# Any time you run updateExtensions.php it may be required to run
# `php maintenance/update.php` since new extension versions may be installed
echo "******* Running update.php to update database as required *******"
cd /var/www/meza1/htdocs/wiki/maintenance
php update.php --quick

# Start Elasticsearch
echo "******* Starting elasticsearch service *******"
service elasticsearch start
sleep 10  # Waits 10 seconds

#
# Generate ES index
#
# Ref: https://git.wikimedia.org/blob/mediawiki%2Fextensions%2FCirrusSearch.git/REL1_25/README
#
echo "******* Generating elasticsearch index *******"

# Add "$wgDisableSearchUpdate = true;" to LocalSettings.php
# Ref: http://stackoverflow.com/questions/525592/find-and-replace-inside-a-text-file-from-a-bash-command
cd /var/www/meza1/htdocs/wiki
sed -i -e 's/\/\/ES-CONFIG-ANCHOR/$wgDisableSearchUpdate = true;/g' LocalSettings.php

# Run script to generate elasticsearch index
php /var/www/meza1/htdocs/wiki/extensions/CirrusSearch/maintenance/updateSearchIndexConfig.php
 
# Remove $wgDisableSearchUpdate = true from LocalSettings.php (updates should start heading to elasticsearch)
sed -i -e 's/$wgDisableSearchUpdate = true;/\/\/ES-CONFIG-ANCHOR/g' LocalSettings.php

# Bootstrap the search index
#
# Note that this can take some time
# For large wikis read "Bootstrapping large wikis" in https://git.wikimedia.org/blob/mediawiki%2Fextensions%2FCirrusSearch.git/REL1_25/README
php /var/www/meza1/htdocs/wiki/extensions/CirrusSearch/maintenance/forceSearchIndex.php --skipLinks --indexOnSkip
php /var/www/meza1/htdocs/wiki/extensions/CirrusSearch/maintenance/forceSearchIndex.php --skipParse
 
# Add "$wgSearchType = 'CirrusSearch';" to LocalSettings.php to funnel queries to ElasticSearch
sed -i -e 's/\/\/ES-CONFIG-ANCHOR/$wgSearchType = "CirrusSearch";/g' LocalSettings.php

echo "******* Complete! *******"
