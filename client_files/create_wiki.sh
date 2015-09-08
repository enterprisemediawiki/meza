#!/usr/bin/sh
#
# Creates a new wiki.
#
# Either call script without params and use prompts or call like:
#    bash create_wiki.sh <wiki_id> <wiki_name> <mysql_root_pass>
# where:
#    wiki_id = Identifier for wiki, and first part of url, like "eng"
#    wiki_name = Human readable name of wiki, like "Engineering Wiki"
#    mysql_root_pass = password for your MySQL root user
#

if [ "$(whoami)" != "root" ]; then
	echo "Try running this script with sudo: \"sudo bash install.sh\""
	exit 1
fi

# If /usr/local/bin is not in PATH then add it
# Ref enterprisemediawiki/Meza1#68 "Run install.sh with non-root user"
if [[ $PATH != *"/usr/local/bin"* ]]; then
	PATH="/usr/local/bin:$PATH"
fi

#
# For now this script is not called within the same shell as install.sh
# and thus it needs to know how to get to the config.sh script on it's own
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR/config.sh"


echo -e "\nCreating new wiki\n"


#
# Wiki ID
#
if [ ! -z "$1" ]; then
    wiki_id="$1"
fi

while [ -z "$wiki_id" ]
do
echo -e "\nEnter the desired wiki identifier. This should be a short "
echo -e "alphanumeric string (no spaces) which will be part of the "
echo -e "URL for your wiki. Example: in the following URL the "
echo -e "\"mywiki\" part is your wiki ID http://example.com/mywiki"
echo -e "\nType the desired wiki ID and press [ENTER]:"
read wiki_id
done

#
# Wiki name
#
if [ ! -z "$2" ]; then
    wiki_name="$2"
fi

while [ -z "$wiki_name" ]
do
echo -e "\nType the desired full wiki name and press [ENTER]: "
read wiki_name
done

#
# MySQL root password
#
if [ ! -z "$3" ]; then
    mysql_root_pass="$3"
fi

while [ -z "$mysql_root_pass" ]
do
echo -e "\nType the MySQL root user's password and press [ENTER]: "
read -s mysql_root_pass
done



cd "$m_htdocs/wikis"


# check if dir already exists
if [ -d "./$wiki_id" ]; then
	echo "Wiki \"$wiki_id\" already exists. Cannot create. Exiting."
	exit 1;
fi

# Check that desired name is alpha-numeric
if grep '^[-0-9a-zA-Z]*$' <<<$wiki_id ; then
	echo "Wiki name is acceptable"
	mkdir "./$wiki_id"
	cp -avr "$m_meza/wiki-init/*" "./$wiki_id/*"
	chown -R apache:www "./$wiki_id/images"
else
	echo "Wiki name is not alphanumeric. Exiting."
	exit 1;
fi


# insert wiki name into setup.php
sed -r -i "s/\$wgSitename = 'placeholder';/\$wgSitename = '$wiki_name';/g;" "./wikis/$wiki_id/setup.php"

# inserter auth type into setup.php
sed -r -i "s/\$mezaAuthType = 'placeholder';/\$mezaAuthType = 'local_dev';/g;" "./wikis/$wiki_id/setup.php"


wiki_db_name="wiki_$wiki_id"

echo -e "\nCreating database and importing tables"
mysql -u root "--password=$mysql_root_pass" -e"CREATE DATABASE IF NOT EXISTS $wiki_db_name; use $wiki_db_name; SOURCE $m_htdocs/mediawiki/maintenance/tables.sql;"

# @todo: initialize site stats?

#
# This will be a major update. All extensions and everything are going to go
# from zero to fully installed.
#
echo -e "\nRun update.php"
WIKI="$wiki_id" php "$m_htdocs/mediawiki/maintenance/update.php"

# This should be done separately. When wikis use a common user table
# then new wikis will not want to create a new user (necessarily)
#
# echo -e "\nCreate first user"
# WIKI="$wiki_id" php /var/www/meza1/mezaCreateUser.php --username=Admin --password=1234 --groups=sysop,bureaucrat


echo "Complete setting up \"$wiki_id\" directory, basic settings and database"




