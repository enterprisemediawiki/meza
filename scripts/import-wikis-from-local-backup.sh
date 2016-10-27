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

if [ -f "/opt/meza/config/local/import-config.sh" ]; then
	source "/opt/meza/config/local/import-config.sh"
fi


#
# Override defaults
#

# Each run of this script should clone the latest version of the wiki. Removing
# the old version is required.
overwrite_existing_wikis=true

# Imports directories are longer-term backups. Don't delete.
keep_imports_directories=true

# Since backup server should be running an identical setup as the production
# server, no need to do database updates.
skip_database_update=true
skip_smw_rebuild=true

source "/opt/meza/scripts/import-wikis.sh"
