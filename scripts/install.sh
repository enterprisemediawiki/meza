#!/bin/bash
#
# Setup the entire meza platform


# Load config constants. Unfortunately right now have to write out full path to
# meza since we can't be certain of consistent method of accessing install.sh.
source "/opt/meza/config/core/config.sh"

source "$m_scripts/shell-functions/base.sh"
rootCheck

source "$m_scripts/shell-functions/logging.sh"

# Override installation defaults
if [ -f "$m_config/local/config.local.sh" ]; then
	exit 1; # get file below
	source "$m_config/local/config.local.sh"
fi


echo -e "\nWelcome to the meza MediaWiki installer\n"


# # # # # # # # # #
#  BEGIN PROMPTS  #
# # # # # # # # # #

# Prompt user for MySQL password
default_mysql_root_pass=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`

while [ -z "$mysql_root_pass" ]; do

	echo -e "\nType your desired MySQL root password"
	echo -e "or leave blank for a randomly generated password and press [ENTER]:"
	read -s mysql_root_pass
	mysql_root_pass=${mysql_root_pass:-$default_mysql_root_pass}

done


# Prompt user for MW API Domain or IP address
while [ -z "$mw_api_domain" ]; do

	# This for loop attempts to find the correct network adapter from which to pull the domain or IP address
	# If multiple adapters are configured (as in our VirtualBox configs), put the most-likely correct one last
	for networkadapter in eth0 eth1 enp0s3 enp0s8
	do
		if [ -n "ip addr | grep $networkadapter | awk 'NR==2 { print $2 }' | awk '-F[/]' '{ print $1 }'" ]; then
			default_mw_api_domain="`ip addr | grep $networkadapter | awk 'NR==2 { print $2 }' | awk '-F[/]' '{ print $1 }'`"
		fi
	done

	echo -e "\nType domain or IP address of your wiki and press [ENTER]:"
	# If the above logic found a value to use as a default suggestion, display it and still prompt user for value
	if [ -n "$default_mw_api_domain" ]; then
		read -e -i $default_mw_api_domain mw_api_domain
	# If the above logic did not find a value to suggest, only read the value in (this fixes #238)
	else
		read -e mw_api_domain
	fi
	mw_api_domain=${mw_api_domain:-$default_mw_api_domain}

done


# # # # # # # #
# END PROMPTS #
# # # # # # # #

source "$m_scripts/firewall.sh"
source "$m_scripts/time-sync.sh"


# @todo: Need to test for yums.sh functionality prior to proceeding
#	with apache.sh, and Apache functionality prior to proceeding
#	with php.sh, and so forth.
cd "$m_meza/scripts"
cmd_tee "source yums.sh"

cd "$m_meza/scripts"
cmd_tee "source imagemagick.sh"

cd "$m_meza/scripts"
cmd_tee "source apache.sh"

cd "$m_meza/scripts"
cmd_tee "source php.sh"

cd "$m_meza/scripts"
cmd_tee "source memcached.sh"

cd "$m_meza/scripts"
cmd_tee "source mariadb.sh"

cd "$m_meza/scripts"
cmd_tee "source VE.sh"

cd "$m_meza/scripts"
cmd_tee "source ElasticSearch.sh"

cd "$m_meza/scripts"
cmd_tee "source mediawiki.sh"

cd "$m_meza/scripts"
cmd_tee "source extensions.sh"

cd "$m_meza/scripts"
cmd_tee "source security.sh"

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

