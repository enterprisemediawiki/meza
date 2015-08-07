#!/bin/bash
#
# Setup MediaWiki (quick--not checking out whole core.git)
#
# Example:
#   bash mediawiki-quick.sh
#
#   This script will prompt the user for several parameters
#

bash printTitle.sh "Begin $0"

# if the script was called in the form:
# bash mediawiki.sh <wiki db name> <wiki name> <wiki admin name> <wiki admin pass>
# then set params accordingly (meaning no user interaction required)
if [ ! -z "$1" ]; then
    wiki_db_name="$1"
fi

if [ ! -z "$2" ]; then
    wiki_name="$2"
fi

if [ ! -z "$3" ]; then
    wiki_admin_name="$3"
fi

if [ ! -z "$4" ]; then
    wiki_admin_pass="$4"
fi

if [ ! -z "$5" ]; then
    mediawiki_git_install="$5"
fi

#
# Prompt for parameters
#
while [ -z "$mysql_root_pass" ]
do
echo -e "\n\nEnter MySQL root password and press [ENTER]: "
read -s mysql_root_pass
done

while [ -z "$wiki_db_name" ]
do
echo -e "\nEnter desired name of your wiki database and press [ENTER]: "
read wiki_db_name
done

while [ -z "$wiki_name" ]
do
echo -e "\nEnter desired name of your wiki and press [ENTER]: "
read wiki_name
done

while [ -z "$wiki_admin_name" ]
do
echo -e "\nEnter desired administrator account username and press [ENTER]: "
read wiki_admin_name
done

while [ -z "$wiki_admin_pass" ]
do
echo -e "\nEnter the password you would like for your wiki administrator account and press [ENTER]: "
read -s wiki_admin_pass
done

while [ -z "$mediawiki_git_install" ]
do
echo -e "\nInstall MediaWiki with git? (y/n) [ENTER]: "
read mediawiki_git_install
done


#
# Install Composer
#
cd ~/sources
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer


#
# Download MediaWiki
#
cd /var/www/meza1/htdocs

if [ "$mediawiki_git_install" = "y" ]; then
	# git clone https://github.com/wikimedia/mediawiki.git wiki
	cmd_profile "START mediawiki git clone"
	git clone https://gerrit.wikimedia.org/r/p/mediawiki/core.git wiki
	cd wiki

	# Checkout latest released version
	git checkout tags/1.25.1
	cmd_profile "END mediawiki git clone"
else
	cmd_profile "START mediawiki get from tarball"
	wget http://releases.wikimedia.org/mediawiki/1.25/mediawiki-core-1.25.1.tar.gz

	mkdir wiki
	tar xpvf mediawiki-core-1.25.1.tar.gz -C ./wiki --strip-components 1
	cd wiki
	cmd_profile "END mediawiki get from tarball"
fi


#
# Give apache the right to modify images
#
chown -R apache:www ./images


#
# Update Composer dependencies
#
cmd_profile "START mediawiki core composer update"
composer update
cmd_profile "END mediawiki core composer update"


#
# Download Vector skin
#
cd skins

if [ "$mediawiki_git_install" = "y" ]; then
	# git clone https://github.com/wikimedia/mediawiki-skins-Vector.git Vector
	git clone https://gerrit.wikimedia.org/r/p/mediawiki/skins/Vector.git Vector
	cd Vector
	git checkout REL1_25
	cd ..
else
	wget https://github.com/wikimedia/mediawiki-skins-Vector/archive/REL1_25.tar.gz
	mkdir Vector
	tar xpvf REL1_25.tar.gz -C ./Vector --strip-components 1
fi


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


#
# Modify LocalSettings.php, set $wgEnableUploads = true;
# Evidently must also set $wgMaxUploadSize = 1024*1024*100; to get over 40MB
#
sed -r -i 's/\$wgEnableUploads\s*=\s*false;/$wgEnableUploads = true;\n$wgMaxUploadSize = 1024*1024*100; \/\/ 100 MB/g;' ./LocalSettings.php


# end of script
echo -e "\n\nMediaWiki has been installed"
