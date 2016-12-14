#!/bin/sh
#
# Get wiki data for import, then perform import

source /opt/meza/config/core/config.sh
source "$m_scripts/shell-functions/base.sh"

# Force root for this operation
rootCheck

# Get data to import
bash "$m_scripts/backup-remote-wikis.sh"

# Import data
bash "$m_scripts/import-wikis.sh"

# Need to update extensions in case individual wikis have different reqs
# FIXME: So should import-wikis.sh update extensions for each wiki imported? An
# imported wiki won't function if additional extensions it requires aren't installed.
bash "$m_scripts/updateExtensions.sh"
