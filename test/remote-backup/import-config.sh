#!/bin/bash
#
# This is a an import-config.sh file for the purposes of testing remote backups





#
# GENERAL
# These settings apply in all cases
#

# MySQL root password for local database
mysql_root_pass="mypassword"

# Use a webhook, or just put "n" for no
slackwebhook="n"

# space-delimited list of wikis you want to import.
# If you want to import all wikis, do `which_wikis="IMPORT_ALL"`
# This may or may not be used in multiple scripts
which_wikis="IMPORT_ALL"

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
# GETTING FILES AND/OR SQL VIA SSH
# Used to make an SSH connection with a server. Note: no setting for password
# for security purposes. Setup SSH keys.
#
remote_domain="domain.com"
remote_ssh_username="yourusername"


#
# LOG FILES for backup-remote-wikis.sh
#

# path for backup logs
backup_logpath="/opt/meza/logs"
