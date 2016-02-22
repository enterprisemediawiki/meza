#!/bin/bash
#
# import one or more wikis

# must be root or sudoer
if [ "$(whoami)" != "root" ]; then
	echo "Try running this script with sudo: \"sudo bash import-wiki.sh\""
	exit 1
fi


# print title of script
bash printTitle.sh "Begin import-wikis.sh"


# If /usr/local/bin is not in PATH then add it
# Ref enterprisemediawiki/meza#68 "Run install.sh with non-root user"
if [[ $PATH != *"/usr/local/bin"* ]]; then
	PATH="/usr/local/bin:$PATH"
fi


#
# For now this script is not called within the same shell as install.sh
# and thus it needs to know how to get to the config.sh script on it's own
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "/opt/meza/config/meza/config.sh"


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


# setup configuration variables
wikis_install_dir="$m_htdocs/wikis"
skipped_wikis=""

# Intended location of $imports_dir (if not creating new wiki): /home/your-user-name/wikis
#
# $imports_dir structured like:
# wikis
#   wiki1
#     images[/|.tar|.tar.gz]
#     wiki.sql
#     config/ (optional logo.png, favicon.ico, setup.php, CustomSettings.php)
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
		echo "$wiki_id directory already exists. Skipping."
		skipped_wikis="$skipped_wikis\n$wiki_id"
		continue
	fi

	mv "$imports_dir/$wiki_id" "$wiki_install_path"
	chmod 755 "$wiki_install_path"

	# Configure images folder
	# Ref: https://www.mediawiki.org/wiki/Manual:Configuring_file_uploads
	chmod 755 "$wiki_install_path/images"
	chown -R apache:apache "$wiki_install_path/images"

	# ideally imported wikis will have a config directory, but if not, create one
	if [ ! -d "$wiki_install_path/config" ]; then
		mkdir "$wiki_install_path/config"
	fi

	# check if logo.png, favicon.ico, setup.php and CustomSettings.php exist. Else use defaults
	if [ ! -f "$wiki_install_path/config/logo.png" ]; then
		cp "$m_config/template/wiki-init/config/logo.png" "$wiki_install_path/config/logo.png"
	fi
	if [ ! -f "$wiki_install_path/config/favicon.ico" ]; then
		cp "$m_config/template/wiki-init/config/favicon.ico" "$wiki_install_path/config/favicon.ico"
	fi
	if [ ! -f "$wiki_install_path/config/overrides.php" ]; then
		cp "$m_config/template/wiki-init/config/overrides.php" "$wiki_install_path/config/CustomSettings.php"
	fi
	if [ ! -f "$wiki_install_path/config/setup.php" ]; then
		cp "$m_config/template/wiki-init/config/setup.php" "$wiki_install_path/config/setup.php"
	fi
	chmod -R 755 "$wiki_install_path/config"

	# insert wiki name and auth type into setup.php if it's still "placeholder"
	sed -r -i "s/wgSitename = 'placeholder';/wgSitename = '$wiki_name';/g;" "$wiki_install_path/config/setup.php"
	sed -r -i "s/mezaAuthType = 'placeholder';/mezaAuthType = 'local_dev';/g;" "$wiki_install_path/config/setup.php"

	# If setup.php already existed, it may have a $mezaCustomDBname set.`This
	# import script normalizes all database names to be in the form
	# "wiki_$wiki_id", so if $wiki_id is "eva" then the database is "wiki_eva"
	#
	# This command just comments out the old database name
	sed -i "s/\$mezaCustomDBname/\/\/ \$mezaCustomDBname/g;" "$wiki_install_path/config/setup.php"

	# import SQL file
	# Import database - Ref: https://www.mediawiki.org/wiki/Manual:Restoring_a_wiki_from_backup
	import_sql_file="$wiki_install_path/wiki.sql"
	wiki_db_name="wiki_$wiki_id"
	echo "For $wiki_db_name: "
	echo " * dropping if exists"
	echo " * (re)creating"
	echo " * importing file at $import_sql_file"
	mysql -u root "--password=$mysql_root_pass" -e"DROP DATABASE IF EXISTS $wiki_db_name; CREATE DATABASE $wiki_db_name; use $wiki_db_name; SOURCE $import_sql_file;"
	rm -rf "$import_sql_file"


	# Run update.php. The database you imported may not be up to the same version
	# as meza, and thus you must update it.
	echo "Running MediaWiki maintenance script \"update.php\""
	WIKI="$wiki_id" php "$m_mediawiki/maintenance/update.php" --quick


	# if SMW set up yet. On the very first install it will not be.
	if [ -d "$m_mediawiki/extensions/SemanticMediaWiki" ]; then
		# Run SMW rebuildData.php
		# Some documenation says to run this in increments of ~3000 pages, but the most
		# recent version of http://semantic-mediawiki.org/wiki/Help:RebuildData.php
		# does not mention that. Attempting without that. If that is required, then
		# will have to determine a method to test for completion of rebuild, and run it
		# in a while loop
		echo "Running Semantic MediaWiki maintenance script \"rebuildData.php\""
		WIKI="$wiki_id" php "$m_mediawiki/extensions/SemanticMediaWiki/maintenance/rebuildData.php" -d 5 -v

		# Run runJobs.php
		# Note that should prob be removed: Daren saw 12k+ jobs in the queue after performing the above steps
		echo "Running MediaWiki maintenance script \"runJobs.php\""
		sed -r -i 's/false/true/g;' "$m_htdocs/wikis/$wiki_id/config/disableSearchUpdate.php"
		WIKI="$wiki_id" php "$m_mediawiki/maintenance/runJobs.php" --quick
		sed -r -i 's/true/false/g;' "$m_htdocs/wikis/$wiki_id/config/disableSearchUpdate.php"
	else
		echo -e "\nSKIPPING SemanticMediaWiki rebuildData.php and runjobs.php (no SMW)"
	fi

	# @FIXME: This has changed. CirrusSearch exists from the beginning now
	# if CirrusSearch extension exists. On first install it will not yet.
	if [ -d "$m_mediawiki/extensions/CirrusSearch" ]; then
		echo "Building Elastic Search index"
		source "$m_meza/scripts/elastic-build-index.sh"
	else
		echo -e "\nSKIPPING elastic-build-index.sh (no CirrusSearch)"
	fi

	complete_msg="Wiki '$wiki_id' has been imported"
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

