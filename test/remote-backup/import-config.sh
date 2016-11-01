#!/bin/bash
#
# This is a an import-config.sh file for the purposes of testing remote backups



# For test purposes, setup some unique values for these
backup_user_name="testuser4321"
temp_pub_key_path="/tmp/pubkey-$backup_user_name"
source_root_user="root" # root=root...duh, but keeping for easy changing later

#
# GETTING FILES AND/OR SQL VIA SSH
# Note: TBD below will be modified by test script
remote_domain=TBD
remote_ssh_username="$backup_user_name" # used by backup-remote-wikis.sh


remote_db_username=root
remote_db_password=TBD

# Location for backups to be stored, e.g. path to your wiki imports
imports_dir="/opt/meza-test-backup"
local_wiki_backup="$imports_dir" # used in backup-remote-wikis.sh



#
# GENERAL
# These settings apply in all cases
#

# MySQL root password for local database
mysql_root_pass=TBD

# Use a webhook, or just put "n" for no
slackwebhook="n"

# space-delimited list of wikis you want to import.
# If you want to import all wikis, do `which_wikis="IMPORT_ALL"`
# This may or may not be used in multiple scripts
which_wikis="IMPORT_ALL"



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
# LOG FILES for backup-remote-wikis.sh
#

# path for backup logs
backup_logpath="/opt/meza/logs"
