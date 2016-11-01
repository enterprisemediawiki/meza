#!/bin/bash
#
# An example config file for handling imports, regardless of import method:
#
#  * import-wikis.sh: Importing wikis from local files
#  * import-remote-wikis: A wrapper on import-wikis.sh which pulls wikis from
#    remote servers via CIFS.

#
# GENERAL
# These settings apply in all cases
#

# MySQL root password for local database
mysql_root_pass="mypassword"

# Use a webhook, or just put "n" for no
slackwebhook="https://hooks.slack.com/your-slack-webhook"

# space-delimited list of wikis you want to import.
# If you want to import all wikis, do `which_wikis="IMPORT_ALL"`
# This may or may not be used in multiple scripts
which_wikis="wiki1 wiki2 wiki3"

# path to your wiki imports
imports_dir="/path/to/wikis"


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




#
# IMPORT REMOTE WIKIS VIA CIFS
# These settings only pertain to doing a CIFS-based import
#


# The mount name is just a convenient identifier for the remote
# server. It can be whatever you want, but should only include
# alphanumeric characters (no spaces). The remote_share is the server
# name and share/directory you have access to on the server.
mount_name="remote-meza"
remote_share="//example.com/some-directory"

# recommended not to set this value, so any user who has access to the share
# can use their own credentials
# remote_username="your-username"

# path from //example.com/some-directory to your wikis directory. Do not lead
# with a slash.
remote_wikis_path="htdocs/wikis"

# Location to pull remote stuf into prior to import.
# FIXME: This ends up just being $imports_dir. Should this var exist?
local_wiki_tmp="/opt/mezawikis"


#
# GETTING DATABASE FILES FROM A REMOTE MYSQL SERVER
#
#

# Database configuration for remote (source) database
remote_db_server="database.example.com"
remote_db_username="database-user"
remote_db_password="database-password"




#
# GETTING FILES AND/OR SQL VIA SSH
# Used to make an SSH connection with a server. Note: no setting for password
# for security purposes. Setup SSH keys.
#
remote_domain="domain.com"
remote_ssh_username="yourusername"


#
# STUFF RELATED TO BACKUPS
# ???
#

# path for backup logs
backup_logpath="/opt/meza/logs"

# path for backup files
# REMOVED $local_wiki_backup. Just use $imports_dir
# local_wiki_backup="/opt/meza/backup"
