#!/bin/bash
#
# backup-remote-wikis.sh
#
# Deletes local wikis and imports a group of wikis from a remote server
#

if [ "$(whoami)" != "root" ]; then
	echo "Try running this script with sudo: \"sudo bash install.sh\""
	exit 1
fi

# If /usr/local/bin is not in PATH then add it
# Ref enterprisemediawiki/meza#68 "Run install.sh with non-root user"
if [[ $PATH != *"/usr/local/bin"* ]]; then
	PATH="/usr/local/bin:$PATH"
fi

#
# Output command to screen and to log files
#
timestamp=$(date "+%Y%m%d%H%M%S")
logpath="/opt/meza/logs" # @fixme: not DRY
outlog="$logpath/${timestamp}_out.log"
errlog="$logpath/${timestamp}_err.log"
cmdlog="$logpath/${timestamp}_cmd.log"

# writes a timestamp with a message for profiling purposes
# Generally use in the form:
# Thu Aug  6 10:44:07 CDT 2015: START some description of action
cmd_profile()
{
	echo "`date`: $*" >> "$cmdlog"
}

# Use tee to send a command output to the terminal, but send stdout
# to a log file and stderr to a different log file. Use like:
# command_to_screen_and_logs "bash yums.sh"
cmd_tee()
{
	cmd_profile "START $*"
	$@ > >(tee -a "$outlog") 2> >(tee -a "$errlog" >&2)
	sleep 1 # why is this needed? It is needed, but why?
	cmd_profile "END $*"
}

# Creates generic title for the beginning of scripts
print_title()
{
cat << EOM

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*                                                             *
*  $*
*                                                             *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

EOM
}

source /opt/meza/config/core/config.sh

if [ -f "/opt/meza/config/local/remote-wiki-config.sh" ]; then
	source "/opt/meza/config/local/remote-wiki-config.sh"
fi

# prompt user for MySQL root password
while [ -z "$mysql_root_pass" ]
do
	echo -e "\nEnter MySQL root password and press [ENTER]: "
	read -s mysql_root_pass
done

# setup configuration variables
wikis_install_dir="$m_htdocs/wikis"

# for each wiki directory
#   drop mysql db
#   remove wiki directory (and all files within)
# Note: $d has trailing slash, like "wiki1/"
cd $wikis_install_dir
for d in */ ; do


	# trim trailing slash from directory name
	# ref: http://stackoverflow.com/questions/1848415/remove-slash-from-the-end-of-a-variable
	# ref: http://www.network-theory.co.uk/docs/bashref/ShellParameterExpansion.html
	wiki_id=${d%/}

	echo "Removing $wiki_id files"
	# TO-DO: Archive files
	rm -rf $wikis_install_dir/$wiki_id
	echo "Complete"

	# drop MySQL database
	wiki_db_name="wiki_$wiki_id"
	echo "Dropping $wiki_db_name database"
	# TO-DO: Archive db dump
	mysql -u root "--password=$mysql_root_pass" -e"DROP DATABASE IF EXISTS $wiki_db_name;"
	echo "Complete"

done


# TO-DO:
#	Make it so this doesn't wipe out a good backup with a bad backup. Maybe keep multiple db dumps.

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



# if not set by remote-wiki-config.sh, then put the wiki data in /opt/mezawikis
# Chose to put in /opt since most likely this directory has lots of space
# regardless of partitioning, since it's where all the wiki data will end up
# anyway.
if [[ -z "$local_wiki_tmp" ]]; then
	local_wiki_tmp="/opt/mezawikis"
fi

# make directory to copy to
if [ ! -d "$local_wiki_tmp" ]; then
  mkdir "$local_wiki_tmp"
fi


echo -e "\n\n\nIMPORTING WIKIS \n"

echo "  Getting files..."

# rsync -avHe ssh "$remote_ssh_username@$remote_domain:$wikis_install_dir" "$local_wiki_tmp"


# TO-DO modify default_which_wikis to only pull directories (not README.md)
default_which_wikis="$(ssh $remote_ssh_username@$remote_domain ls $wikis_install_dir)"
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
	# rsync -rva "./$wiki/" "$local_wiki_tmp/$wiki"
	rsync -avHe ssh "$remote_ssh_username@$remote_domain:$wikis_install_dir/$wiki/" "$local_wiki_tmp/$wiki"

	wiki_pre_localsettings="$local_wiki_tmp/$wiki/config/preLocalSettings.php"
	if [ ! -f "$wiki_pre_localsettings" ]; then
		# maintain old method of getting wiki db
		echo -e "\nThere is no preLocalSettings.php file; using setup.php instead\n"
		wiki_pre_localsettings="$local_wiki_tmp/$wiki/config/setup.php"
	fi

	wiki_db=`php /opt/meza/scripts/getDatabaseNameFromSetup.php $wiki_pre_localsettings`
	if [ -z "$wiki_db" ]; then
		wiki_db="wiki_$wiki"
	fi

	echo "  Getting database..."
	ssh "$remote_ssh_username@$remote_domain" mysqldump -u $remote_db_username --password=$remote_db_password $wiki_db > "$local_wiki_tmp/$wiki/wiki.sql"
	# mysqldump -v -h $remote_db_server -u $remote_db_username -p$remote_db_password $wiki_db > "$local_wiki_tmp/$wiki/wiki.sql"

done

imports_dir="$local_wiki_tmp"
source /opt/meza/scripts/import-wikis.sh
