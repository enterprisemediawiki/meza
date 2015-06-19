#!/bin/bash
#
# Setup MediaWiki (quick--not checking out whole core.git)
#
# Example:
#   bash mediawiki-quick.sh
#
#   This script will prompt the user for several parameters
#

#
# Prompt for parameters
#
while [ -z "$mysql_root_pass" ]
do
echo -e "\n\n\n\nEnter MySQL root password and press [ENTER]: "
read -s mysql_root_pass
done

while [ -z "$wiki_db_name" ]
do
echo -e "\n\nEnter desired name of your wiki database and press [ENTER]: "
read wiki_db_name
done

while [ -z "$wiki_name" ]
do
echo -e "\n\nEnter desired name of your wiki and press [ENTER]: "
read wiki_name
done

while [ -z "$wiki_admin_name" ]
do
echo -e "\n\nEnter desired administrator account username and press [ENTER]: "
read wiki_admin_name
done

while [ -z "$wiki_admin_pass" ]
do
echo -e "\n\nEnter the password you would like for your wiki administrator account and press [ENTER]: "
read -s wiki_admin_pass
done


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
tar xpvf REL1_25.tar.gz -C ./Vector --strip-components 1


#
# Install MW with install.php
#
cd ..
php maintenance/install.php \
	--dbtype mysql \
	--dbuser root \
	--dbpass "$mysql_root_pass" \
	--dbname "$wiki_db_name" \
	--pass "$wiki_admin_pass" \
	"$wiki_name" "$wiki_admin_name" \
	--scriptpath /wiki
