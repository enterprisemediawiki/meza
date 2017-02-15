#!/bin/bash
#
# Setup the entire meza platform


# Load config constants. Unfortunately right now have to write out full path to
# meza since we can't be certain of consistent method of accessing install.sh.
source "/opt/meza/config/core/config.sh"

source "$m_scripts/shell-functions/base.sh"
rootCheck

source "$m_scripts/shell-functions/logging.sh"

echo -e "\nWelcome to the meza MediaWiki installer\n"


# # # # # # # # # #
#  BEGIN PROMPTS  #
# # # # # # # # # #

meza prompt_secure mysql_root_pass   "Type your desired MySQL root password"
meza prompt        mw_api_domain     "Type domain or IP address of your wiki"
meza prompt        server_ip_address "Type IP address of this server"

# meza "prompt" command writes config changes to config.local, but those
# changes don't immediately show up in this shell, so need to re-source
# the config file after changes.
source "$m_local_config_file"

# # # # # # # #
# END PROMPTS #
# # # # # # # #

# going through the items below, add to array those which apply.
# then loop through the array for:
#  1. prompts
#  2. yum
#  3. install module

# modules="firewall time-sync yums"

# for module in $modules; do
# 	source "$m_modules/$module/prompts.sh"
# done

# for module in $modules; do
# 	 "$m_modules/$module/packages.txt"
# 	echo "$string" | tr '\n' ' '
# done




# @todo: Need to test for yums.sh functionality prior to proceeding
#	with apache.sh, and Apache functionality prior to proceeding
#	with php.sh, and so forth.
cmd_tee "source $m_scripts/firewall.sh"
cmd_tee "source $m_scripts/time-sync.sh"
cmd_tee "source $m_scripts/yums.sh"

if [ "$is_app_server" = true ]; then
	cmd_tee "source $m_scripts/imagemagick.sh"
	cmd_tee "source $m_scripts/apache.sh"
	cmd_tee "source $m_scripts/php.sh"
	cmd_tee "source $m_scripts/memcached.sh"
fi

if [ "$setup_database" = true ]; then
	cmd_tee "source $m_scripts/mariadb.sh"
fi

if [ "$setup_parsoid" = true ]; then
	cmd_tee "source $m_scripts/VE.sh"
fi

if [ "$setup_elasticsearch" ]; then
	cmd_tee "source $m_scripts/ElasticSearch.sh"
fi

if [ "$is_app_server" = true ]; then
	cmd_tee "source $m_scripts/mediawiki.sh"
	cmd_tee "source $m_scripts/extensions.sh"
fi

cmd_tee "source $m_scripts/security.sh"


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

