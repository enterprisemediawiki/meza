#!/bin/bash
#
# Allows importing a group of wikis from a remote server (or separate remote
# application and database servers).
#

if [ -f "/opt/meza/config/local/remote-wiki-config.sh" ]; then
	source "/opt/meza/config/local/remote-wiki-config.sh"
fi


# Ask for mount name
while [ -z "$mount_name" ]
do
	echo "The mount name is just a convenient identifier for the remote"
	echo "server. It can be whatever you want, but should only include"
	echo "alphanumeric characters (no spaces). "
	echo "Enter name of mount and press [ENTER]: "
	read mount_name
done

# remote share name
while [ -z "$remote_share" ]
do
	echo -e "\nEnter name of your remote share drive and press [ENTER]: "
	echo "  (Format like: //server.com/directory)"
	read remote_share
done

# Ask for remote_username
while [ -z "$remote_username" ]
do
	echo -e "\nEnter the username for the remote share and press [ENTER]: "
	read remote_username
done


# create mount
mkdir "/mnt/$mount_name"
mount.cifs "$remote_share" "/mnt/$mount_name" -o "user=$remote_username"


# make directory to copy to
mkdir /root/wikis


# list directory of mount point
cd "/mnt/$mount_name"
echo -e "\nYour server path is $remote_share/"
echo -e "\nThe sub-directories in that directory are:"
for d in */ ; do
    echo "  $d"
done



# Ask for path to wikis within remote sahre
while [ -z "$remote_wikis_path" ]
do
	echo -e "\nEnter path from this remote share to your wikis directory and press [ENTER]: "
	echo -e "\nThis should not include a leading slash and should look like: path/to/wikis"
	read remote_wikis_path
done

full_remote_wikis_path="/mnt/$mount_name/$remote_wikis_path"

# List all wiki directories, prompt user for which to retrieve (blank = all)
cd "$full_remote_wikis_path"
default_which_wikis=""
echo "The following wikis are available:"
for d in */ ; do
    echo "  $d"
	default_which_wikis="$default_which_wikis $d"
done

# check if already set (via remote-wiki-config.sh file)
if [ -z "$which_wikis" ]; then
	# Prompt user for which wikis to import
	echo -e "\nType which wikis you would like to import, separated by spaces"
	echo -e "or leave blank to import all wikis and press [ENTER]:"
	read which_wikis
fi
which_wikis=${which_wikis:-$default_which_wikis}

# remote-wiki-config.sh method for getting all wikis is to set which_wikis to IMPORT_ALL
if [ "$which_wikis" = "IMPORT_ALL" ]; then
	which_wikis="$default_which_wikis"
fi

# Ask for mysql root password
while [ -z "$mysql_root_pass" ]
do
	echo -e "\nEnter your local MySQL root password and press [ENTER]: "
	read -s mysql_root_pass
done


#
# Database credentials for remote database
#
while [ -z "$remote_db_server" ]
do
	echo -e "\nEnter the server name for the remote database server and press [ENTER]: "
	read remote_db_server
done

while [ -z "$remote_db_username" ]
do
	echo -e "\nEnter the username for the remote database and press [ENTER]: "
	read remote_db_username
done

while [ -z "$remote_db_password" ]
do
	echo -e "\nEnter the password for the remote database and press [ENTER]: "
	read -s remote_db_password
done



echo
echo
echo "Announce completion of each wiki on Slack?"
echo "Enter webhook URI or leave blank to opt out:"
read slackwebhook

if [[ -z "$slackwebhook" ]]; then
	slackwebhook="n"
fi

echo -e "\n\n\nIMPORTING WIKIS: $which_wikis\n"

cd "$full_remote_wikis_path"

# copy each selected wiki directory, then get database
for wiki_dir in $which_wikis
do

	# trim trailing slash from directory name
	# ref: http://stackoverflow.com/questions/1848415/remove-slash-from-the-end-of-a-variable
	# ref: http://www.network-theory.co.uk/docs/bashref/ShellParameterExpansion.html
	wiki=${wiki_dir%/}

	# @todo: delete existing wiki data?
	echo "Starting import of wiki '$wiki'"

	echo "  Getting files..."
	rsync -rva "./$wiki/" "/root/wikis/$wiki"

	wiki_pre_localsettings="$full_remote_wikis_path/$wiki/config/preLocalSettings.php"
	if [ ! -f "$wiki_pre_localsettings" ]; then
		# maintain old method of getting wiki db
		echo -e "\nThere is no preLocalSettings.php file; using setup.php instead\n"
		wiki_pre_localsettings="$full_remote_wikis_path/$wiki/config/setup.php"
	fi

	wiki_db=`php /opt/meza/scripts/getDatabaseNameFromSetup.php $wiki_pre_localsettings`
	if [ -z "$wiki_db" ]; then
		wiki_db="wiki_$wiki"
	fi

	echo "  Getting database..."
	mysqldump -v -h $remote_db_server -u $remote_db_username -p$remote_db_password $wiki_db > "/root/wikis/$wiki/wiki.sql"

done

imports_dir=/root/wikis
source /opt/meza/scripts/import-wikis.sh

