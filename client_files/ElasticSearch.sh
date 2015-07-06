#
# This script installs Extension:CirrusSearch
# which provides Elasticsearch for MediaWiki
# 
# Dependencies
# - PHP compiled with cURL
# - Elasticsearch
#   - JAVA 7+
# - Extension:Elastica
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
# Try this for JDK 8: http://tecadmin.net/install-java-8-on-centos-rhel-and-fedora/
#wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jdk-8u45-linux-x64.rpm
#rpm -ivh jdk-8u45-linux-x64.rpm

# Verify JAVA is installed
java -version

# Set $JAVA_HOME # Is this required?
# http://askubuntu.com/questions/175514/how-to-set-java-home-for-openjdk
echo "JAVA_HOME=\"/usr/bin\"" >> /etc/environment
source /etc/environment
echo $JAVA_HOME 

# Install Elasticsearch via yum repository
#
# https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-repositories.html
# 

# Download and install the public signing key:
echo "******* Downloading and installing public signing key *******"
cd ~/sources/meza1/client_files
rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch

# Add yum repo file
echo "******* Downloading yum repo file for Elasticsearch *******"
cd ~/sources/meza1/client_files
#wget https://raw.githubusercontent.com/enterprisemediawiki/Meza1/installElasticSearch/client_files/elasticsearch.repo
cp ./elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo

# Install repo
echo "******* Installing yum repo file for Elasticsearch *******"
yum -y install elasticsearch

# Configure Elasticsearch to automatically start during bootup
echo "******* Configuring Elasticsearch to start on boot *******"
chkconfig --add elasticsearch

# *** MANUAL INSTALLATION OPTION (delete) ***
#cd ~/sources
#curl -L -O https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.6.0.tar.gz
#tar -xvf elasticsearch-1.6.0.tar.gz
#cp -r elasticsearch-1.6.0 /etc/elasticsearch-1.6.0
#cd /etc/elasticsearch-1.6.0/bin

#
# Elasticsearch Configuration
#
# https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-configuration.html
# 

# Add host name per https://github.com/elastic/elasticsearch/issues/6611
echo "127.0.0.1 Meza1" >> /etc/hosts

# Rename the standard config file and copy over our custom config file
cd /etc/elasticsearch
mv ./elasticsearch.yml ./elasticsearch-old.yml
cd ~/sources/meza1/client_files
# wget https://raw.githubusercontent.com/enterprisemediawiki/Meza1/installElasticSearch/client_files/elasticsearch.yml
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
echo "******* Downloading extensions *******"
cd ~/sources/meza1/client_files
# Add Elastica and CirrusSearch to ExtensionSettings
# TODO: This part can be modified if the user gets this file in the initial VM setup script
#wget https://raw.githubusercontent.com/enterprisemediawiki/Meza1/installElasticSearch/client_files/ExtensionSettingsElasticSearch.php
cp ~/sources/meza1/client_files/ExtensionSettingsElasticSearch.php /var/www/meza1/htdocs/wiki/ExtensionSettingsElasticSearch.php
cat /var/www/meza1/htdocs/wiki/ExtensionSettingsElasticSearch.php >> /var/www/meza1/htdocs/wiki/ExtensionSettings.php

#
# MW Configuration
# 

# Add CirrusSearch settings to LocalSettings.php
echo "******* Downloading configuration files *******"
cd ~/sources/meza1/client_files
#wget https://raw.githubusercontent.com/enterprisemediawiki/Meza1/installElasticSearch/client_files/LocalSettingsElasticSearch.php
cp ~/sources/meza1/client_files/LocalSettingsElasticSearch.php /var/www/meza1/htdocs/wiki/LocalSettingsElasticSearch.php
cat /var/www/meza1/htdocs/wiki/LocalSettingsElasticSearch.php >> /var/www/meza1/htdocs/wiki/LocalSettings.php

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
service elasticsearch start

# Incorporate steps from https://git.wikimedia.org/blob/mediawiki%2Fextensions%2FCirrusSearch.git/REL1_25/README
#Add this to LocalSettings.php:
# $wgDisableSearchUpdate = true;
 
# Now run this script to generate your elasticsearch index:
php /var/www/meza1/htdocs/wiki/extensions/CirrusSearch/maintenance/updateSearchIndexConfig.php
 
# Now remove $wgDisableSearchUpdate = true from LocalSettings.php.  Updates should start heading to Elasticsearch.
 
#Next bootstrap the search index by running:
# php $MW_INSTALL_PATH/extensions/CirrusSearch/maintenance/forceSearchIndex.php --skipLinks --indexOnSkip
# php $MW_INSTALL_PATH/extensions/CirrusSearch/maintenance/forceSearchIndex.php --skipParse
#Note that this can take some time.  For large wikis read "Bootstrapping large wikis" below.
 
#Once that is complete add this to LocalSettings.php to funnel queries to ElasticSearch:
# $wgSearchType = 'CirrusSearch';

# Lots of things to add from
# https://www.mediawiki.org/wiki/Extension:CirrusSearch
# https://en.wikipedia.org/w/api.php?action=cirrus-config-dump&srbackend=CirrusSearch&format=json
# https://git.wikimedia.org/blob/mediawiki%2Fextensions%2FCirrusSearch.git/REL1_25/README
#
echo "******* Complete! *******"
