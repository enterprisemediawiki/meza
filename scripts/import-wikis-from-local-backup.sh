#!/bin/bash
#
# import-wikis-from-local-backup.sh
#
# Import wikis from backup files after using backup-remote-wikis.sh
#

if [ "$(whoami)" != "root" ]; then
	echo "Try running this script with sudo: \"sudo bash import-wikis-from-local-backup.sh\""
	exit 1
fi

# If /usr/local/bin is not in PATH then add it
# Ref enterprisemediawiki/meza#68 "Run install.sh with non-root user"
if [[ $PATH != *"/usr/local/bin"* ]]; then
	PATH="/usr/local/bin:$PATH"
fi

source /opt/meza/config/core/config.sh

if [ -f "/opt/meza/config/local/remote-wiki-config.sh" ]; then
	source "/opt/meza/config/local/remote-wiki-config.sh"
fi

#
# Logging info
#
timestamp=$(date "+%Y%m%d%H%M%S")
# default_backup_logpath="~/logs"
# if [ -z "$backup_logpath" ]; then
# 	# Prompt user for place to store backup logs
# 	echo -e "\nType the path to store log files"
# 	echo -e "or leave blank to use your user directory and press [ENTER]:"
# 	read backup_logpath
# fi
# backup_logpath=${backup_logpath:-$default_backup_logpath}
# # backup_logpath="/home/root/logs"
# cronlog="$backup_logpath/${timestamp}_cron.log"


# prompt user for local MySQL root password
while [ -z "$mysql_root_pass" ]
do
	echo -e "\nEnter local MySQL root password and press [ENTER]: "
	read -s mysql_root_pass
done


# if not set by remote-wiki-config.sh, then put the wiki data in /opt/mezawikis
# Chose to put in /opt since most likely this directory has lots of space
# regardless of partitioning, since it's where all the wiki data will end up
# anyway.
if [ -z "$local_wiki_backup" ]; then
	# Prompt user for place to store backup files
	echo -e "\nType the path to store backup files"
	echo -e "and press [ENTER]:"
	read local_wiki_backup
fi

# make directory to copy to
if [ ! -d "$local_wiki_backup" ]; then
  mkdir "$local_wiki_backup"
fi


echo -e "\n\n\nIMPORTING WIKIS \n"


default_which_wikis="$(ssh -q $remote_ssh_username@$remote_domain 'cd /opt/meza/htdocs/wikis; for d in */; do wiki_id=${d%/}; default_which_wikis="$default_which_wikis $wiki_id"; done; echo $default_which_wikis')"


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

# Announce start of backup on Slack if a slack webhook provided
if [[ ! -z "$slackwebhook" ]]; then
	bash "/opt/meza/scripts/slack.sh" "$slackwebhook" "Starting import from backup for the following wikis at $timestamp:  $which_wikis" ""

fi



# copy most recent backup files to temp dir for import
cp -r $local_wiki_backup $local_wiki_tmp

# for each wiki directory
for wiki in $which_wikis
do

	# remove all but most-recent sql file
	# Ref: http://stackoverflow.com/a/4447795/5103312
	cd $local_wiki_backup/$wiki
	find . -maxdepth 1 -type f -iname "*.sql" | sort -r | tail -n +2 | xargs rm -f

	# rename remaining sql file to generic filename suitable for import script
	mv ./*.sql ./wiki.sql

done


imports_dir="$local_wiki_tmp"
source /opt/meza/scripts/import-wikis.sh



# Announce completion of backup on Slack if a slack webhook provided
if [[ ! -z "$slackwebhook" ]]; then
	bash "/opt/meza/scripts/slack.sh" "$slackwebhook" "Your meza backup import is complete!" ""

	# Announce errors on Slack if any were logged
	# Commented out because it's broken it doesn't work someone should lose their job
	# if [ ! -e "$cronlog" ]; then
	# 	announce_log=`cat $cronlog`
	# 	bash "/opt/meza/scripts/slack.sh" "$slackwebhook" "$announce_log" "$cmd_times"
	# fi

fi
