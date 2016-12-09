#!/bin/bash
#
# Setup the entire meza platform


# Load config constants. Unfortunately right now have to write out full path to
# meza since we can't be certain of consistent method of accessing install.sh.
source "/opt/meza/config/core/config.sh"

source "$m_scripts/shell-functions/base.sh"
rootCheck

source "$m_scripts/shell-functions/logging.sh"

# This will be re-sourced after prompts to get modified config, but needs to be
# here mostly to get $modules variable
source "$m_local_config_file"

# i18n message file
source "$m_i18n/$m_language.sh"

echo -e "\nWelcome to the meza MediaWiki installer\n"


# going through the items below, add to array those which apply.
# then loop through the array for:
#  1. prompts
#  2. things that need to be done before yum
#  3. yum installs
#  4. install module


#
# Prompt for required info
#
for module in $modules; do
	if [ -f "$m_modules/$module/prompts.sh" ]; then
		source "$m_modules/$module/prompts.sh"
	fi
done

# meza "prompt" command writes config changes to config.local, but those
# changes don't immediately show up in this shell, so need to re-source
# the config file after changes.
source "$m_local_config_file"

#
# Run pre-setup scripts if required (these are things that must preceed
# yum-installs, like loading repositories)
#
for module in $modules; do
	if [ -f "$m_modules/$module/pre-setup.sh" ]; then
		printTitle "Starting module:$module:pre-setup"
		cmd_tee "source $m_modules/$module/pre-setup.sh"
	fi
done

#
# Get list of packages to install with yum, then install them
#
packages=""
for module in $modules; do
	mod_package_file="$m_modules/$module/packages.txt"
	if [ -f "$mod_package_file" ]; then
		while IFS='' read -r line || [[ -n "$line" ]]; do
			if [ -z "$line" ]; then
				echo "blank line"
			elif [[ "$line" = \#* ]]; then
				echo "line starts with hash: $line"
			else
				echo "Adding package: $line"
				packages="$packages $line"
			fi
		done < "$mod_package_file"
	fi
done
printTitle "Yum installing packages"
echo "doing: yum -y install $packages"
yum -y install $packages

#
# Run module init scripts
#
# @todo: Need to test for yums.sh functionality prior to proceeding
#	with apache.sh, and Apache functionality prior to proceeding
#	with php.sh, and so forth.
for module in $modules; do
	if [ -f "$m_modules/$module/init.sh" ]; then
		printTitle "Starting module:$module:init"
		cmd_tee "source $m_modules/$module/init.sh"
	fi
done


# Remove GitHub API personal access token from .composer dir
# @todo: change the following to instead just remove the token from the file
#		in case there are other authentication entries
rm -f ~/.composer/auth.json


# print time requirements for each script
echo "COMMAND TIMES:"
cmd_times=`node "$m_meza/scripts/commandTimes.js" "$cmdlog"`
echo "$cmd_times"

# Announce on Slack if a slack webhook provided
if [[ ! -z "$slackwebhook" ]]; then
	announce_domain=`cat "$m_config/local/domain"`
	bash "$m_meza/scripts/slack.sh" "$slackwebhook" "Your meza installation $announce_domain is complete. Install times:" "$cmd_times"
fi

# Display Most Plusquamperfekt Wiki Pigeon of Victory
cat "$m_meza/scripts/pigeon.txt"

