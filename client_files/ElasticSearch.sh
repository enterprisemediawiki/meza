#
# This script installs Extension:CirrusSearch
# which provides Elastic Search for MediaWiki
# 
# Dependencies
# - PHP compiled with cURL
# - Elasticsearch
# - Extension:Elastica
# 

#
# Install Elasticsearch
#

# Download and install the public signing key:
echo "******* Downloading and installing public signing key *******"
rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch

# Add yum repo file
echo "******* Downloading yum repo file *******"
cd ~/sources/meza1/client_files
wget https://raw.githubusercontent.com/enterprisemediawiki/Meza1/installElasticSearch/client_files/elasticsearch.repo
cp elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo

# Install repo
echo "******* Downloading yum repo file *******"
yum install elasticsearch

# Configure Elasticsearch to automatically start during bootup
echo "******* Configuring Elasticsearch to start on boot *******"
chkconfig --add elasticsearch

# TODO: Start elasticsearch at this point or is there configuration to add?
# service elasticsearch start

#
# Install Extension:Elastica and Extension:CirrusSearch
#
echo "******* Downloading extensions *******"
cd ~/sources/meza1/client_files
# Add Elastica and CirrusSearch to ExtensionSettings
# TODO: This part can be modified if the user gets this file in the initial VM setup script
wget https://raw.githubusercontent.com/enterprisemediawiki/Meza1/installElasticSearch/client_files/ExtensionSettingsElasticSearch.php
cp ExtensionSettingsElasticSearch.php /var/www/meza1/htdocs/wiki/ExtensionSettingsElasticSearch.php
cat /var/www/meza1/htdocs/wiki/ExtensionSettingsElasticSearch.php >> /var/www/meza1/htdocs/wiki/ExtensionSettings.php

#
# Configuration
#

# Add CirrusSearch settings to LocalSettings.php
echo "******* Downloading configuration files *******"
cd ~/sources/meza1/client_files
wget https://raw.githubusercontent.com/enterprisemediawiki/Meza1/installElasticSearch/client_files/LocalSettingsElasticSearch.php
cp LocalSettingsElasticSearch.php /var/www/meza1/htdocs/wiki/LocalSettingsElasticSearch.php
cat /var/www/meza1/htdocs/wiki/LocalSettingsElasticSearch.php >> /var/www/meza1/htdocs/wiki/LocalSettings.php


# Lots of things to add from
# https://www.mediawiki.org/wiki/Extension:CirrusSearch
# https://en.wikipedia.org/w/api.php?action=cirrus-config-dump&srbackend=CirrusSearch&format=json
# https://git.wikimedia.org/blob/mediawiki%2Fextensions%2FCirrusSearch.git/REL1_25/README
#

# Run updateExtensions to install UniversalLanguageSelector and VisualEditor
echo "******* Installing extensions *******"
php /var/www/meza1/htdocs/wiki/extensions/ExtensionLoader/updateExtensions.php
# Not sure if composer install is required - see: https://www.mediawiki.org/wiki/Extension:Elastica
# composer install


echo "******* Complete! *******"
