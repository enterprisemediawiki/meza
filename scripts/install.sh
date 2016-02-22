#!/bin/bash
#
# Setup the entire meza platform

if [ "$(whoami)" != "root" ]; then
	echo "Try running this script with sudo: \"sudo bash install.sh\""
	exit 1
fi

# If /usr/local/bin is not in PATH then add it
# Ref enterprisemediawiki/meza#68 "Run install.sh with non-root user"
if [[ $PATH != *"/usr/local/bin"* ]]; then
	PATH="/usr/local/bin:$PATH"
fi

echo -e "\nWelcome to meza v0.4\n"


#
# Set architecture to 32 or 64 (bit)
#
if [ $(uname -m | grep -c 64) -eq 1 ]; then
architecture=64
else
architecture=32
fi


#
# CentOS/RHEL version 7 or 6?
#
# note: /etc/os-release does not exist in CentOS 6, but this works anyway
if grep -Fxq "VERSION_ID=\"7\"" /etc/os-release
then
    echo "Setting Enterprise Linux version to \"7\""
    enterprise_linux_version=7

	# Make sure firewalld is enabled and started (it's not on Digital Ocean)
	# This should be done as soon as possible to make sure we're protected early
	systemctl enable firewalld
	systemctl start firewalld

else
    echo "Setting Enterprise Linux version to \"6\""
    enterprise_linux_version=6
fi

# Perform prompts
source "$m_meza/scripts/install_prompts.sh"

# Prompt user for MW API protocol -- ASSUME HTTPS. Perhaps we'll remove this assumption later
# default_mw_api_protocol="http"
# echo -e "\nType http or https for MW API and press [ENTER]:"
# read -e -i $default_mw_api_protocol mw_api_protocol
# mw_api_protocol=${mw_api_protocol:-$default_mw_api_protocol}
mw_api_protocol=https


# Set Parsoid version.
# This should be able to be set in any of these forms:
#   9260e5d       (a sha1 hash)
#   tags/v0.4.1   (a tag name)
#   master        (a branch name)
parsoid_version="ba26a55"

phpversion="5.6.14"

# Check if git installed, and install it if required
if ! hash git 2>/dev/null; then
    echo "************ git not installed, installing ************"
    yum install git -y
fi

# if no mezadownloads directory, create it
# source files will be downloaded here and deleted later
if [ ! -d ~/mezadownloads ]; then
	mkdir ~/mezadownloads
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

# function to install meza via git
install_via_git()
{
	cd /opt
	git clone https://github.com/enterprisemediawiki/meza meza
	cd meza
	git checkout "$git_branch"
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


# no meza directory
if [ ! -d /opt/meza ]; then
	install_via_git

# meza exists, but is not a git repo (hold over from older versions of meza)
elif [ ! -d /opt/meza/.git ]; then
	rm -rf /opt/meza
	install_via_git

# meza exists and is a git repo: checkout latest branch
else
	cd /opt/meza
	git fetch origin
	git checkout "$git_branch"
fi


# Load config constants. Unfortunately right now have to write out full path to
# meza since we can't be certain of consistent method of accessing install.sh.
source /opt/meza/config/meza/config.sh

# Enable time sync
# Ref: http://www.cyberciti.biz/faq/howto-install-ntp-to-synchronize-server-clock/
yum -y install ntp ntpdate ntp-doc # Install packages for time sync
chkconfig ntpd on # Activate service
ntpdate pool.ntp.org # Synchronize the system clock with 0.pool.ntp.org server
service ntpd start # Start service
# Optionally configure ntpd via /etc/ntp.conf

# @todo: Need to test for yums.sh functionality prior to proceeding
#    with apache.sh, and Apache functionality prior to proceeding
#    with php.sh, and so forth.
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
cmd_tee "source mysql.sh"

cd "$m_meza/scripts"
cmd_tee "source VE.sh"

cd "$m_meza/scripts"
cmd_tee "source ElasticSearch.sh"

cd "$m_meza/scripts"
cmd_tee "source mediawiki.sh"

cd "$m_meza/scripts"
cmd_tee "source extensions.sh"

# Remove GitHub API personal access token from .composer dir
# @todo: change the following to instead just remove the token from the file
#        in case there are other authentication entries
rm -f ~/.composer/auth.json

# remove downloads directory (miscellaneous downloaded files)
rm -rf /root/mezadownloads

# print time requirements for each script
echo "COMMAND TIMES:"
cmd_times=`node "$m_meza/scripts/commandTimes.js" "$cmdlog"`
echo "$cmd_times"

# Announce on Slack if a slack webhook provided
if [[ ! -z "$slackwebhook" ]]; then
	bash "$m_meza/scripts/slack.sh" "$slackwebhook" "Your meza installation is complete. Install times:" "$cmd_times"
fi

# Display Most Plusquamperfekt Wiki Pigeon of Victory
cat "$m_meza/scripts/pigeon.txt"

