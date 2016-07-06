#!/bin/bash
#
# backup-remote-wikis.sh
#
# Back up files and db from remote server wiki farm
#

# Note this requires a dummy user with an ssh key pair to prevent prompts for ssh password
# http://www.thegeekstuff.com/2008/11/3-steps-to-perform-ssh-login-without-password-using-ssh-keygen-ssh-copy-id/
# On backup server as user OscarRogers:
#	ssh-keygen (hit <enter> three times)
# 	scp ~/.ssh/id_rsa.pub OscarRogers@remotehost:/home/OscarRogers/
# On production server as user OscarRogers:
#	mkdir /home/OscarRogers/.ssh
# 	cat id_rsa.pub >> /home/OscarRogers/.ssh/authorized_keys
#	Permissions changes may be required
#	https://www.digitalocean.com/community/questions/i-can-t-ssh-with-root-or-setup-keys-properly


if [ "$(whoami)" != "root" ]; then
	echo "Try running this script with sudo: \"sudo bash backup-remote-wikis.sh\""
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
# backup_logpath="/home/root/logs"
# cronlog="$backup_logpath/${timestamp}_cron.log"


# prompt user for local MySQL root password
while [ -z "$mysql_root_pass" ]
do
	echo -e "\nEnter local MySQL root password and press [ENTER]: "
	read -s mysql_root_pass
done

# remote wikis installation directory
wikis_install_dir="$m_htdocs/wikis"



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
	bash "/opt/meza/scripts/slack.sh" "$slackwebhook" "Starting backup for the following wikis at $timestamp:  $which_wikis" "$cmd_times"

fi

# copy each selected wiki directory, then get database
for wiki_dir in $which_wikis
do

	# trim trailing slash from directory name
	# ref: http://stackoverflow.com/questions/1848415/remove-slash-from-the-end-of-a-variable
	# ref: http://www.network-theory.co.uk/docs/bashref/ShellParameterExpansion.html
	wiki=${wiki_dir%/}

	echo "Starting import of wiki '$wiki'"

	# make directory to copy to
	if [ ! -d "$local_wiki_backup/$wiki" ]; then
	  mkdir "$local_wiki_backup/$wiki"
	fi

	echo "  Getting files..."
	# Announce file getting on Slack if a slack webhook provided
	# if [[ ! -z "$slackwebhook" ]]; then
	# 	bash "/opt/meza/scripts/slack.sh" "$slackwebhook" "Getting $wiki files" "$cmd_times"

	# fi

	rsync -avHe ssh -q "$remote_ssh_username@$remote_domain:$wikis_install_dir/$wiki/" "$local_wiki_backup/$wiki"

	wiki_pre_localsettings="$local_wiki_backup/$wiki/config/preLocalSettings.php"
	if [ ! -f "$wiki_pre_localsettings" ]; then
		# maintain old method of getting wiki db
		echo -e "\nThere is no preLocalSettings.php file; using setup.php instead\n"
		wiki_pre_localsettings="$local_wiki_backup/$wiki/config/setup.php"
	fi

	wiki_db=`php /opt/meza/scripts/getDatabaseNameFromSetup.php $wiki_pre_localsettings`
	if [ -z "$wiki_db" ]; then
		wiki_db="wiki_$wiki"
	fi

	echo "  Getting database..."
	# Announce db getting on Slack if a slack webhook provided
	# if [[ ! -z "$slackwebhook" ]]; then
	# 	bash "/opt/meza/scripts/slack.sh" "$slackwebhook" "Getting $wiki db" "$cmd_times"

	# fi
	ssh -q $remote_ssh_username@$remote_domain mysqldump -u $remote_db_username --password=$remote_db_password $wiki_db > "$local_wiki_backup/$wiki/${timestamp}_wiki.sql"


	# remove sql old sql files, keep 7 most-recent files
	# Ref: http://stackoverflow.com/a/4447795/5103312
	cd $local_wiki_backup/$wiki
	find . -maxdepth 1 -type f -iname "*.sql" | sort -r | tail -n +8 | xargs rm -f

done

# # Announce file and db transfer complete, start import on Slack if a slack webhook provided
# if [[ ! -z "$slackwebhook" ]]; then
# 	bash "/opt/meza/scripts/slack.sh" "$slackwebhook" "Beginning to build your wiki farm" "$cmd_times"

# fi

# imports_dir="$local_wiki_tmp"
# source /opt/meza/scripts/import-wikis.sh



# Announce completion of backup on Slack if a slack webhook provided
if [[ ! -z "$slackwebhook" ]]; then
	bash "/opt/meza/scripts/slack.sh" "$slackwebhook" "Your meza backup is complete!" "$cmd_times"

	# Announce errors on Slack if any were logged
	# Commented out because it's broken it doesn't work someone should lose their job
	# if [ ! -e "$cronlog" ]; then
	# 	announce_log=`cat $cronlog`
	# 	bash "/opt/meza/scripts/slack.sh" "$slackwebhook" "$announce_log" "$cmd_times"
	# fi

fi
