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
	cp -avr "$m_meza/wiki-init" "$imports_dir/$wiki_id"

	# get SQL file from MediaWiki
	echo "Copying MediaWiki tables.sql"
	cp -avr "$m_mediawiki/maintenance/tables.sql" "$imports_dir/$wiki_id/wiki.sql"

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
		cp "$m_meza/wiki-init/config/logo.png" "$wiki_install_path/config/logo.png"
	fi
	if [ ! -f "$wiki_install_path/config/favicon.ico" ]; then
		cp "$m_meza/wiki-init/config/favicon.ico" "$wiki_install_path/config/favicon.ico"
	fi
	if [ ! -f "$wiki_install_path/config/CustomSettings.php" ]; then
		cp "$m_meza/wiki-init/config/CustomSettings.php" "$wiki_install_path/config/CustomSettings.php"
	fi
	if [ ! -f "$wiki_install_path/config/setup.php" ]; then
		cp "$m_meza/wiki-init/config/setup.php" "$wiki_install_path/config/setup.php"
	fi
	if [ ! -f "$wiki_install_path/config/disableSearchUpdate.php" ]; then
		cp "$m_meza/wiki-init/config/disableSearchUpdate.php" "$wiki_install_path/config/disableSearchUpdate.php"
	fi

	# insert wiki name and auth type into setup.php if it's still "placeholder"
	sed -r -i "s/wgSitename = 'placeholder';/wgSitename = '$wiki_name';/g;" "$wiki_install_path/config/setup.php"
	sed -r -i "s/mezaAuthType = 'placeholder';/mezaAuthType = 'local_dev';/g;" "$wiki_install_path/config/setup.php"

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
	# as Meza1, and thus you must update it.
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
		WIKI="$wiki_id" php "$m_mediawiki/maintenance/runJobs.php" --quick
	else
		echo -e "\nSKIPPING SemanticMediaWiki rebuildData.php and runjobs.php (no SMW)"
	fi

	# if CirrusSearch extension exists. On first install it will not yet.
	if [ -d "$m_mediawiki/extensions/CirrusSearch" ]; then
		echo "Building Elastic Search index"
		source "$m_meza/scripts/elastic-build-index.sh"
	else
		echo -e "\nSKIPPING elastic-build-index.sh (no CirrusSearch)"
	fi

	echo -e "\nWiki \"$wiki_id\" has been imported\n"

	# delete remaining source files?

done

# In order for the new wiki(s) to use Visual Editor, must restart Parsoid
service parsoid restart

echo -e "\nImport complete!"

if [ "$skipped_wikis" != "" ]; then
	echo "The following wikis were skipped:"
	echo "$skipped_wikis"
fi

