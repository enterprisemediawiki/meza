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

# setup configuration variables
wikis_install_dir="$m_htdocs/wikis"

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
#
# TO-DO: remove these copy commands and just copy during import below
#
# rm -rf $local_wiki_tmp
# cp -r $local_wiki_backup $local_wiki_tmp

# for each wiki directory, copy most recent sql dump to temp dir for import
#
# TO-DO: remove these  commands and just source latest sql during import below
#
# for wiki in $which_wikis
# do

# 	# remove all but most-recent sql file
# 	# Ref: http://stackoverflow.com/a/4447795/5103312
# 	cd $local_wiki_tmp/$wiki
# 	find . -maxdepth 1 -type f -iname "*.sql" | sort -r | tail -n +2 | xargs rm -f

# 	# rename remaining sql file to generic filename suitable for import script
# 	mv ./*.sql ./wiki.sql

# done


imports_dir="$local_wiki_backup"
# Commands below were adapted from /opt/meza/scripts/import-wikis.sh

cd $imports_dir
for d in */ ; do


	# trim trailing slash from directory name
	# ref: http://stackoverflow.com/questions/1848415/remove-slash-from-the-end-of-a-variable
	# ref: http://www.network-theory.co.uk/docs/bashref/ShellParameterExpansion.html
	wiki_id=${d%/}

	echo "Starting $wiki_id"

	wiki_install_path="$wikis_install_dir/$wiki_id"

	if [ -d "$wiki_install_path" ]; then
		echo "$wiki_id directory already exists. Removing."
		rm -rf $wiki_install_path
	fi

	# This assumes we only need to copy the /config and /images directories from the backup set (to excluse sql files)
	# We may need to modify this later if the architecture changes
	mkdir "$wiki_install_path"
	cp -r "$imports_dir/$wiki_id/config" "$wiki_install_path/config"
	cp -r "$imports_dir/$wiki_id/images" "$wiki_install_path/images"
	chmod 755 "$wiki_install_path"

	# Configure images folder
	# Ref: https://www.mediawiki.org/wiki/Manual:Configuring_file_uploads
	chmod 755 "$wiki_install_path/images"
	chown -R apache:apache "$wiki_install_path/images"

	# ideally imported wikis will have a config directory, but if not, create one
	if [ ! -d "$wiki_install_path/config" ]; then
		mkdir "$wiki_install_path/config"
	fi

	# check if logo.png, favicon.ico, preLocalSettings.php and postLocalSettings_allWikis.php exist. Else use defaults
	if [ ! -f "$wiki_install_path/config/logo.png" ]; then
		cp "$m_config/template/wiki-init/config/logo.png" "$wiki_install_path/config/logo.png"
	fi
	if [ ! -f "$wiki_install_path/config/favicon.ico" ]; then
		cp "$m_config/template/wiki-init/config/favicon.ico" "$wiki_install_path/config/favicon.ico"
	fi
	if [ ! -f "$wiki_install_path/config/postLocalSettings.php" ]; then
		# old method used overrides.php...rename that file if it exists
		if [ -f "$wiki_install_path/config/overrides.php" ]; then
			mv "$wiki_install_path/config/overrides.php" "$wiki_install_path/config/postLocalSettings.php"
		else
			cp "$m_config/template/wiki-init/config/postLocalSettings.php" "$wiki_install_path/config/postLocalSettings.php"
		fi
	fi
	if [ ! -f "$wiki_install_path/config/preLocalSettings.php" ]; then
		# old method used setup.php...rename that file if it exists
		if [ -f "$wiki_install_path/config/setup.php" ]; then
			mv "$wiki_install_path/config/setup.php" "$wiki_install_path/config/preLocalSettings.php"
		else
			cp "$m_config/template/wiki-init/config/preLocalSettings.php" "$wiki_install_path/config/preLocalSettings.php"
		fi
	fi
	chmod -R 755 "$wiki_install_path/config"

	# insert wiki name and auth type into preLocalSettings.php if it's still "placeholder"
	sed -r -i "s/wgSitename = 'placeholder';/wgSitename = '$wiki_name';/g;" "$wiki_install_path/config/preLocalSettings.php"

	# If preLocalSettings.php already existed, it may have a $mezaCustomDBname set.
	# This import script normalizes all database names to be in the form
	# "wiki_$wiki_id", so if $wiki_id is "eva" then the database is "wiki_eva"
	#
	# This command just comments out the old database name
	sed -i "s/\$mezaCustomDBname/\/\/ \$mezaCustomDBname/g;" "$wiki_install_path/config/preLocalSettings.php"

	# import SQL file
	# Import database - Ref: https://www.mediawiki.org/wiki/Manual:Restoring_a_wiki_from_backup

	# determine and use most-recent sql file
	# Ref: http://stackoverflow.com/a/4447795/5103312
	import_sql_file="$(find $local_wiki_backup/$wiki_id -maxdepth 1 -type f -iname "*.sql" | sort -r | head -n +1)"
	wiki_db_name="wiki_$wiki_id"
	echo "For $wiki_db_name: "
	echo " * dropping if exists"
	echo " * (re)creating"
	echo " * importing file at $import_sql_file"
	mysql -u root "--password=$mysql_root_pass" -e"DROP DATABASE IF EXISTS $wiki_db_name; CREATE DATABASE $wiki_db_name; use $wiki_db_name; SOURCE $import_sql_file;"
	#
	# TO-DO: Remove the following rm command; don't remove sql file from backup dir, just use it
	# rm -rf "$import_sql_file"


	# Run update.php. The database you imported may not be up to the same version
	# as meza, and thus you must update it.
	#
	# TO-DO: update.php commented-out for now; may not be necessary
	#
	# echo "Running MediaWiki maintenance script \"update.php\""
	# WIKI="$wiki_id" php "$m_mediawiki/maintenance/update.php" --quick


	# if SMW set up yet. On the very first install it will not be.
	#
	# TO-DO: SMW maintenance commented-out for now; may not be necessary
	#
	# if [ -d "$m_mediawiki/extensions/SemanticMediaWiki" ]; then
	# 	# Run SMW rebuildData.php
	# 	# Some documenation says to run this in increments of ~3000 pages, but the most
	# 	# recent version of http://semantic-mediawiki.org/wiki/Help:RebuildData.php
	# 	# does not mention that. Attempting without that. If that is required, then
	# 	# will have to determine a method to test for completion of rebuild, and run it
	# 	# in a while loop
	# 	rebuild_exception_log="$m_meza/logs/rebuilddata-exceptions-$wiki_id-.log"
	# 	echo "Running Semantic MediaWiki maintenance script \"rebuildData.php\""
	# 	WIKI="$wiki_id" php "$m_mediawiki/extensions/SemanticMediaWiki/maintenance/rebuildData.php" -d 5 -v --ignore-exceptions --exception-log="$rebuild_exception_log"

	# 	# Run runJobs.php
	# 	# Note that should prob be removed: Daren saw 12k+ jobs in the queue after performing the above steps
	# 	echo "Running MediaWiki maintenance script \"runJobs.php\""
	# 	echo "\$wgDisableSearchUpdate = true;" >> "$m_htdocs/wikis/$wiki_id/config/postLocalSettings.php"
	# 	WIKI="$wiki_id" php "$m_mediawiki/maintenance/runJobs.php" --quick
	# 	sed -r -i 's/\$wgDisableSearchUpdate = true;//g;' "$m_htdocs/wikis/$wiki_id/config/postLocalSettings.php"
	# else
	# 	echo -e "\nSKIPPING SemanticMediaWiki rebuildData.php and runjobs.php (no SMW)"
	# fi

	complete_msg="Wiki '$wiki_id' has been imported"
	if [[ -f "$rebuild_exception_log" ]]; then
		complete_msg="$complete_msg\nSemanticMediaWiki rebuildData exceptions:\n\n$(cat $rebuild_exception_log)"
	fi
	echo -e "\n$complete_msg\n"
	if [[ ! -z "$slackwebhook" ]]; then
		bash "$m_meza/scripts/slack.sh" "$slackwebhook" "$complete_msg"
	fi

	# delete remaining source files?

done

# In order for the new wiki(s) to use Visual Editor, must restart Parsoid
service parsoid restart

echo -e "\nImport complete!"

echo -e "\nBuilding search indices"
# Announce building search indices on Slack if a slack webhook provided
if [[ ! -z "$slackwebhook" ]]; then
	bash "/opt/meza/scripts/slack.sh" "$slackwebhook" "Building search indices for each wiki" ""

fi

cd $wikis_install_dir
for d in */ ; do

	# trim trailing slash from directory name
	# ref: http://stackoverflow.com/questions/1848415/remove-slash-from-the-end-of-a-variable
	# ref: http://www.network-theory.co.uk/docs/bashref/ShellParameterExpansion.html
	wiki_id=${d%/}

	# Announce building search indices on Slack if a slack webhook provided
	if [[ ! -z "$slackwebhook" ]]; then
		bash "/opt/meza/scripts/slack.sh" "$slackwebhook" "Starting $wiki_id" ""

	fi

	echo "Building Elastic Search index for $wiki_id"
	source "$m_meza/scripts/elastic-build-index.sh"

done



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
