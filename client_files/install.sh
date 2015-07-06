#!/bin/bash
#
# Setup the entire Meza1 platform


# if the script was called in the form:
# bash install <architecture> \
#              <phpversion> \
#              <mysql_root_pass> \
#              <wiki_db_name> \
#              <wiki_name> \
#              <wiki_admin_name> \
#              <wiki_admin_pass>
# then set params accordingly (meaning no user interaction required)
if [ ! -z "$1" ]; then
    architecture="$1"
fi

if [ ! -z "$2" ]; then
    phpversion="$2"
fi

if [ ! -z "$3" ]; then
    mysql_root_pass="$3"
fi

if [ ! -z "$4" ]; then
    wiki_db_name="$4"
fi

if [ ! -z "$5" ]; then
    wiki_name="$5"
fi

if [ ! -z "$6" ]; then
    wiki_admin_name="$6"
fi

if [ ! -z "$7" ]; then
    wiki_admin_pass="$7"
fi


# Force user to pick an architecture: 32 or 64 bit
while [ "$architecture" != "32" ] && [ "$architecture" != "64" ]
do
echo -e "\n\n\n\nWhich architecture are you using? Type 32 or 64 and press [ENTER]: "
read architecture
done

# Prompt user for PHP version
while [ -z "$phpversion" ]
do
echo -e "\n\n\n\nVisit http://php.net/downloads.php"
echo -e "\nEnter the version of PHP you would like (such as 5.4.42) and press [ENTER]: "
read phpversion
done

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


cd ~/sources/meza1/client_files
bash yums.sh "$architecture" || exit 1
bash apache.sh || exit 1
bash php.sh "$phpversion" || exit 1
bash mysql.sh "$mysql_root_pass" || exit 1

# bash mediawiki-quick.sh <mysql pass> <wiki db name> <wiki name> <wiki admin name> <wiki admin pass>
bash mediawiki-quick.sh "$mysql_root_pass" "$wiki_db_name" "$wiki_name" "$wiki_admin_name" "$wiki_admin_pass" || exit 1

bash extensions.sh || exit 1
bash VE.sh || exit 1
