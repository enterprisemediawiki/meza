#!/bin/bash
#
# Setup MediaWiki


#
# Install Composer
#
cd ~/sources
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer


#
# Download MediaWiki via Git
#
cd /var/www/meza1/htdocs
#git clone https://git.wikimedia.org/git/mediawiki/core.git wiki
git clone https://github.com/wikimedia/mediawiki.git wiki
cd wiki

#
# Checkout latest released version
#
git checkout tags/1.25.1


#
# Update Composer dependencies
#
composer update


#
# Install Vector skin and checkout latest
#
cd skins
# git clone https://git.wikimedia.org/git/mediawiki/skins/Vector.git
git clone https://github.com/wikimedia/mediawiki-skins-Vector.git Vector
cd Vector
git checkout REL1_25

