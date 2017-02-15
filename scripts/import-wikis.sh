#!/bin/bash
#
# import one or more wikis

# must be root or sudoer
if [ "$(whoami)" != "root" ]; then
	echo "Try running this script with sudo: \"sudo bash import-wiki.sh\""
	exit 1
fi


# If /usr/local/bin is not in PATH then add it
# Ref enterprisemediawiki/meza#68 "Run install.sh with non-root user"
if [[ $PATH != *"/usr/local/bin"* ]]; then
	PATH="/usr/local/bin:$PATH"
fi


# meza core config info
source "/opt/meza/config/core/config.sh"


# print title of script
bash printTitle.sh "Begin import-wikis.sh"


# INITIALIZE DEFAULTS. These can be overridden in import-config.sh (sourced below).

# Default: Don't wipe out existing wikis
overwrite_existing_wikis=false

# Default: Move files to final locations and don't duplicate on file system
keep_imports_directories=false

# Default: Run update.php after import
# (may not be required for imports from identical meza systems)
skip_database_update=false

# Default: Rebuild SMW data after import
# (may not be required for imports from identical meza systems)
skip_smw_rebuild=false


if [ -f "/opt/meza/config/local/import-config.sh" ]; then
	source "/opt/meza/config/local/import-config.sh"
fi


# setup configuration variables
wikis_install_dir="$m_htdocs/wikis"
skipped_wikis=""

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


# Prompt user for locations of wiki data
while [ -z "$imports_dir" ]
do
echo -e "Enter path to your wiki imports and press [ENTER]: "
read imports_dir
done


# prompt user for MySQL root password
while [ -z "$mysql_root_pass" ]
do
echo -e "\nEnter MySQL root password and press [ENTER]: "
read -s mysql_root_pass
done


if [ "$imports_dir" = "new" ]; then

	while [ -z "$wiki_id" ]; do
		echo ""
		echo "Enter the desired wiki identifier. This should be a short"
		echo "alphanumeric string (no spaces) which will be part of the"
		echo "URL for your wiki. For example, in the following URL the"
		echo '"mywiki" part is your wiki ID: https://example.com/mywiki'
		echo ""
		echo "Type the desired wiki ID and press [ENTER]:"
		read wiki_id
	done

	while [ -z "$wiki_name" ]; do
		echo ""
		echo "The wiki name should name should be short, but not as short"
		echo "as the wiki ID. It can be a little more descriptive, and"
		echo "should also use capitalization where appropriate."
		echo "Example: Engineering Wiki"
		echo ""
		echo "Type the desired wiki name and press [ENTER]:"
		read wiki_name
	done


	# this is sort of a hacky way to emulate the import process
	#
	cd /tmp
	if [ -d ./wikis ]; then
		rm -rf ./wikis
	fi
	mkdir wikis
	imports_dir="/tmp/wikis"
	cp -avr "$m_config/template/wiki-init" "$imports_dir/$wiki_id"

	# get SQL file from MediaWiki
	echo "Copying MediaWiki tables.sql"
	cp -avr "$m_mediawiki/maintenance/tables.sql" "$imports_dir/$wiki_id/wiki.sql"

fi


if [[ -z "$slackwebhook" ]]; then
	echo
	echo
	echo "Announce completion of each wiki on Slack?"
	echo "Enter webhook URI or leave blank to opt out:"
	read slackwebhook
fi


# Intended location of $imports_dir (if not creating new wiki): /home/your-user-name/wikis
#
# $imports_dir structured like:
# wikis
#   wiki1
#     images[/|.tar|.tar.gz]
#     wiki.sql
#     config/ (optional logo.png, favicon.ico, preLocalSettings.php, postLocalSettings.php)
#   wiki2
#     ...
#   wikiN
#
# Note: $d has trailing slash, like "wiki1/"
cd $imports_dir
for d in */ ; do

	# trim trailing slash from directory name
	# ref: http://stackoverflow.com/questions/1848415/remove-slash-from-the-end-of-a-variable
	# ref: http://www.network-theory.co.uk/docs/bashref/ShellParameterExpansion.html
	wiki_id=${d%/}

	echo "Starting $wiki_id"

	wiki_install_path="$wikis_install_dir/$wiki_id"

	if [ -d "$wiki_install_path" ]; then

		if [ "$overwrite_existing_wikis" = "true" ]; then
			echo "$wiki_id directory already exists. Removing."
			rm -rf $wiki_install_path
		else
			echo "$wiki_id directory already exists. Skipping."
			skipped_wikis="$skipped_wikis\n$wiki_id"
			continue
		fi
	fi

	# new-backups-import
	# This assumes we only need to copy the /config and /images directories from the backup set (to excluse sql files)
	# We may need to modify this later if the architecture changes


	# Create directory for wiki. We do not simply move the $imports_dir/$wiki_id
	# directory because this may also include several additional files (namely
	# SQL files) which are not required
	mkdir "$wiki_install_path"


	if [ "$keep_imports_directories" = "true" ]; then

		cp -r "$imports_dir/$wiki_id/config" "$wiki_install_path/config"
		cp -r "$imports_dir/$wiki_id/images" "$wiki_install_path/images"

	else

		mv "$imports_dir/$wiki_id/config" "$wiki_install_path/config"
		mv "$imports_dir/$wiki_id/images" "$wiki_install_path/images"
		# Note: we'll remove the $imports_dir/$wiki_id directory at the end of the loop

	fi

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

	# if a file exists called wiki.sql, use that. Else use the latest timestamped
	import_sql_file="$wiki_install_path/wiki.sql"
	if [ ! -f "$import_sql_file" ]; then
		# wiki.sql does not exist. Determine and use most-recent sql file
		# Ref: http://stackoverflow.com/a/4447795/5103312
		import_sql_file="$(find $imports_dir/$wiki_id -maxdepth 1 -type f -iname "*.sql" | sort -r | head -n +1)"
	fi

	# If SQL file still not found we can't complete this import. Skip this wiki
	# FIXME: perhaps this should be performed earlier before files are moved
	if [ ! -f "$import_sql_file" ]; then
		continue;
	fi

	# import SQL file
	# Import database - Ref: https://www.mediawiki.org/wiki/Manual:Restoring_a_wiki_from_backup
	wiki_db_name="wiki_$wiki_id"
	echo "For $wiki_db_name: "
	echo " * dropping if exists"
	echo " * (re)creating"
	echo " * importing file at $import_sql_file"
	mysql -u root "--password=$mysql_root_pass" -e"DROP DATABASE IF EXISTS $wiki_db_name; CREATE DATABASE $wiki_db_name; use $wiki_db_name; SOURCE $import_sql_file;"

	# Remove the SQL file unless directed to keep it
	if [ "$keep_imports_directories" = "false" ]; then
		rm -rf "$import_sql_file"
	fi

	# Run update.php. The database you imported may not be up to the same version
	# of meza, and then you must update it. If you know the database is for the
	# same version of meza you can choose not to run this for time-savings. If
	# you're not sure you should run it.
	if [ "$skip_database_update" = "false" ]; then
		echo "Running MediaWiki maintenance script \"update.php\""
		WIKI="$wiki_id" php "$m_mediawiki/maintenance/update.php" --quick
	fi

	if [ "$skip_smw_rebuild" = "true" ]; then

		echo
		echo "SKIPPING SemanticMediaWiki rebuildData.php and runjobs.php per user direction"

	# if SMW set up yet. On the very first install it will not be.
	elif [ -d "$m_mediawiki/extensions/SemanticMediaWiki" ]; then
		# Run SMW rebuildData.php
		# Some documenation says to run this in increments of ~3000 pages, but the most
		# recent version of http://semantic-mediawiki.org/wiki/Help:RebuildData.php
		# does not mention that. Attempting without that. If that is required, then
		# will have to determine a method to test for completion of rebuild, and run it
		# in a while loop
		rebuild_exception_log="$m_meza/logs/rebuilddata-exceptions-$wiki_id-.log"
		echo "Running Semantic MediaWiki maintenance script \"rebuildData.php\""
		WIKI="$wiki_id" php "$m_mediawiki/extensions/SemanticMediaWiki/maintenance/rebuildData.php" -d 5 -v --ignore-exceptions --exception-log="$rebuild_exception_log"

		# Run runJobs.php
		# Note that should prob be removed: Daren saw 12k+ jobs in the queue after performing the above steps
		echo "Running MediaWiki maintenance script \"runJobs.php\""
		echo "\$wgDisableSearchUpdate = true;" >> "$m_htdocs/wikis/$wiki_id/config/postLocalSettings.php"
		WIKI="$wiki_id" php "$m_mediawiki/maintenance/runJobs.php" --quick
		sed -r -i 's/\$wgDisableSearchUpdate = true;//g;' "$m_htdocs/wikis/$wiki_id/config/postLocalSettings.php"

	# SMW not set up yet (for new installations). Skip it.
	else
		echo
		echo "SKIPPING SemanticMediaWiki rebuildData.php and runjobs.php (no SMW)"
	fi


	#
	# Completion of import (not search index, yet)
	#
	complete_msg="Wiki '$wiki_id' has been imported"
	if [[ -f "$rebuild_exception_log" ]]; then
		complete_msg="$complete_msg\nSemanticMediaWiki rebuildData exceptions:\n\n$(cat $rebuild_exception_log)"
	fi

	# Check if anything remains in $imports_dir/$wiki_id. If so don't delete, but report it.
	if [ "$(ls -A $1)" ]; then
		complete_msg="$complete_msg\n\nImport directory $imports_dir/$wiki_id is not empty. Not deleting."
	else
		rm "$imports_dir/$wiki_id"
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

if [ "$skipped_wikis" != "" ]; then
	echo "The following wikis were skipped:"
	echo "$skipped_wikis"
fi


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
		bash "/opt/meza/scripts/slack.sh" "$slackwebhook" "Starting $wiki_id search index" ""

	fi

	echo "Building Elastic Search index for $wiki_id"
	source "$m_meza/scripts/elastic-build-index.sh"

done



# Announce completion of backup on Slack if a slack webhook provided
if [[ ! -z "$slackwebhook" ]]; then
	bash "/opt/meza/scripts/slack.sh" "$slackwebhook" "Your meza import and indexing is complete!" ""

	# Announce errors on Slack if any were logged
	# Commented out because it's broken it doesn't work someone should lose their job
	# if [ ! -e "$cronlog" ]; then
	# 	announce_log=`cat $cronlog`
	# 	bash "/opt/meza/scripts/slack.sh" "$slackwebhook" "$announce_log" "$cmd_times"
	# fi

fi
