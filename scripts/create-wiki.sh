#!/bin/bash
#
# This script is a wrapper on `import-wikis.sh`. By setting the $imports_dir
# variable it overrides the import script's mechanism for finding the source for
# new wikis and instead installs a new wiki.

source "/opt/meza/config/core/config.sh"

source "$m_scripts/shell-functions/base.sh"
rootCheck

source "$m_local_config_file"


# Set $imports_dir to "new", so import-wikis.sh won't attempt to import existing wikis
imports_dir="new"

# For creating a wiki, don't announce on Slack. Creating a wiki is quick.
originalslackwebhook="$slackwebhook"
meza config slackwebhook "n"

# Run import script
source "$m_scripts/import-wikis.sh"

# Reset slackwebhook to whatever it started as
meza config slackwebhook "$originalslackwebhook"
