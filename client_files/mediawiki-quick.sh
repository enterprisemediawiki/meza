#!/bin/bash
#
# Setup MediaWiki (quick--not checking out whole core.git)
#
# Example:
#   bash mediawiki-quick.sh <mysql-root-pass> <wiki-admin-pass>
#
#   $1: mysql-root-pass: the password for your mysql root user
#   $2: wiki-admin-pass: the user "Admin" will be created for this wiki
#       and this will be used as Admin's password
#


#
# Install Composer
#
cd ~/sources
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer


#
# Download MediaWiki from tarball
#
cd /var/www/meza1/htdocs
wget http://releases.wikimedia.org/mediawiki/1.25/mediawiki-core-1.25.1.tar.gz

mkdir wiki
tar xpvf mediawiki-core-1.25.1.tar.gz -C ./wiki --strip-components 1
cd wiki


#
# Give apache the right to modify images
#
chown -R apache:www ./images


#
# Update Composer dependencies
#
composer update


#
# Download Vector skin tarball, REL1_25 branch
#
cd skins
wget https://github.com/wikimedia/mediawiki-skins-Vector/archive/REL1_25.tar.gz
mkdir Vector
tar xpvf mediawiki-skins-Vector-REL1_25.tar.gz -C ./Vector --strip-components 1


#
# Install MW with install.php
#
cd ..
php maintenance/install.php \
	--dbtype mysql \
	--dbuser root \
	--dbpass "$1" \
	--dbname wiki_test \
	--pass "$2" \
	TestWiki Admin \
	--scriptpath /wiki

