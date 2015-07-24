#!/bin/bash
#
# Using a SQL file and a directory of images, import a wiki

# Prior to running, first:
# 
# 1) On your current wiki, create an images.tar.gz file from your wiki's
#    images directory:
#    tar -cvzf images.tar.gz ./images/*
# 
# 2) Run mysqldump on your wiki and create wiki.sql:
#    mysqldump -h localhost -u root -p WIKI_DB_NAME > /path/to/save/wiki.sql
#    replace WIKI_DB_NAME with your wiki's database name
#
# 3) Copy both files into your new server's /var/www/meza1 directory. How to do
#    this is up to you. You can use scp, pscp (on Windows, with Putty), you can
#    setup a shared directory with your VM. If your current wiki is on the open
#    Internet you can make the files available via HTTP and use wget or cURL to
#    pull them onto your new server. Your choice!
#
#    To use Secure Copy use the `scp` command
#    On Windows use `pscp` after downloading from TBD
#    (p)scp /path/to/wiki.sql user@example.com:/var/www/meza1
#    (p)scp /path/to/images.tar.gz user@example.com:/var/www/meza1
#    replace "/path/to", "user", and "example.com" accordingly
#
# 4) Run this script


# must be root or sudoer
if [ "$(whoami)" != "root" ]; then
	echo "Try running this script with sudo: \"sudo bash install.sh\""
	exit 1
fi


# print title of script
bash printTitle.sh "Begin $0"


# If /usr/local/bin is not in PATH then add it
# Ref enterprisemediawiki/Meza1#68 "Run install.sh with non-root user"
if [[ $PATH != *"/usr/local/bin"* ]]; then
  PATH="/usr/local/bin:$PATH"
fi


# Prompt user for wiki database name
while [ -z "$wiki_db_name" ]
do
echo -e "Enter name of your wiki database and press [ENTER]: "
read wiki_db_name
done


# prompt user for MySQL root password
while [ -z "$mysql_root_pass" ]
do
echo -e "\nEnter MySQL root password and press [ENTER]: "
read -s mysql_root_pass
done


# setup configuration variables
meza1_root="/var/www/meza1"
wiki_root="$meza1_root/wiki"
smw_root="$wiki_root/extensions/SemanticMediaWiki"
wiki_sql_file="$meza1_root/wiki.sql"
wiki_images="$meza1_root/images.tar.gz"
cd "$meza1_root/htdocs/wiki"


# un-zip images directory
tar -zxvf "$wiki_images"
rm ./images/README.md
rm ./images/.htaccess
mv ./images/* "$wiki_root/images/*"


# Configure images folder
# Ref: https://www.mediawiki.org/wiki/Manual:Configuring_file_uploads
chmod 755 /images
chown -R apache:apache /images


# Import database - Ref: https://www.mediawiki.org/wiki/Manual:Restoring_a_wiki_from_backup
echo "For $wiki_db_name: "
echo " * dropping if exists"
echo " * (re)creating"
echo " * importing file at $wiki_sql_file"
mysql -u root "--password=$mysql_root_pass" -e"DROP DATABASE IF EXISTS $wiki_db_name; CREATE DATABASE $wiki_db_name; use $wiki_db_name; SOURCE $wiki_sql_file;"


# Run update.php. The database you imported may not be up to the same version
# as Meza1, and thus you must update it.
echo "Running MediaWiki maintenance script \"update.php\"" 
php maintenance/update.php --quick


# Run SMW rebuildData.php
# Some documenation says to run this in increments of ~3000 pages, but the most
# recent version of http://semantic-mediawiki.org/wiki/Help:RebuildData.php
# does not mention that. Attempting without that. If that is required, then
# will have to determine a method to test for completion of rebuild, and run it
# in a while loop
echo "Running Semantic MediaWiki maintenance script \"rebuildData.php\""
cd "$smw_root/maintenance"
php rebuildData.php -d 5 -v


# Run runJobs.php (Daren saw 12k+ jobs in the queue after performing the above steps)
echo "Running MediaWiki maintenance script \"runJobs.php\""
cd "$wiki_root/maintenance"
php runJobs.php --quick


echo -e "\nYour wiki has been imported!\n"
