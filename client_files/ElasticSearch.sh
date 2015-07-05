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
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jdk-8u45-linux-x64.rpm
rpm -ivh jdk-8u45-linux-x64.rpm
java --version
echo $JAVA_HOME

#
# Install Elasticsearch
#
# https://www.elastic.co/guide/en/elasticsearch/reference/current/_installation.html
# https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-repositories.html
# 

# Download and install the public signing key:
echo "******* Downloading and installing public signing key *******"
rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch

# Add yum repo file
echo "******* Downloading yum repo file for Elasticsearch *******"
cd ~/sources/meza1/client_files
wget https://raw.githubusercontent.com/enterprisemediawiki/Meza1/installElasticSearch/client_files/elasticsearch.repo
cp ~/sources/meza1/client_files/elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo

# Install repo
echo "******* Installing yum repo file for Elasticsearch *******"
yum -y install elasticsearch

# Configure Elasticsearch to automatically start during bootup
echo "******* Configuring Elasticsearch to start on boot *******"
chkconfig --add elasticsearch

#
# Elasticsearch Configuration
#
# https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-configuration.html
# 

# TODO: Start elasticsearch at this point or is there configuration to add?
# service elasticsearch start #options:  --cluster.name my_cluster_name --node.name my_node_name

#
# Install Extension:Elastica and Extension:CirrusSearch
#
echo "******* Downloading extensions *******"
cd ~/sources/meza1/client_files
# Add Elastica and CirrusSearch to ExtensionSettings
# TODO: This part can be modified if the user gets this file in the initial VM setup script
wget https://raw.githubusercontent.com/enterprisemediawiki/Meza1/installElasticSearch/client_files/ExtensionSettingsElasticSearch.php
cp ~/sources/meza1/client_files/ExtensionSettingsElasticSearch.php /var/www/meza1/htdocs/wiki/ExtensionSettingsElasticSearch.php
cat /var/www/meza1/htdocs/wiki/ExtensionSettingsElasticSearch.php >> /var/www/meza1/htdocs/wiki/ExtensionSettings.php

#
# MW Configuration
# 

# Add CirrusSearch settings to LocalSettings.php
echo "******* Downloading configuration files *******"
cd ~/sources/meza1/client_files
wget https://raw.githubusercontent.com/enterprisemediawiki/Meza1/installElasticSearch/client_files/LocalSettingsElasticSearch.php
cp ~/sources/meza1/client_files/LocalSettingsElasticSearch.php /var/www/meza1/htdocs/wiki/LocalSettingsElasticSearch.php
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
