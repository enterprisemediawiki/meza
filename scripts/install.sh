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

# Prompt user for git branch
default_git_branch="master"
echo -e "\nType the git branch of meza you want to use and press [ENTER]:"
read -e -i $default_git_branch git_branch
git_branch=${git_branch:-$default_git_branch}

# Prompt user for GitHub API personal access token
default_usergithubtoken="e9191bc6d394d64011273d19f4c6be47eb10e25b" # From Oscar Rogers
echo -e "\nIf you run this script multiple times from one IP address,"
echo -e "you might exceed GitHub's API rate limit."
echo -e "\nYou may just press [ENTER] to use our generic token (which may exceed limits if used too much) or"
echo -e "Visit https://github.com/settings/tokens to generate a new token (with no scopes)."
echo -e "and copy/paste your 40-character token and press [ENTER]: "
read usergithubtoken
usergithubtoken=${usergithubtoken:-$default_usergithubtoken}

# Set Parsoid version.
# This should be able to be set in any of these forms:
#   9260e5d       (a sha1 hash)
#   tags/v0.4.1   (a tag name)
#   master        (a branch name)
parsoid_version="ba26a55"

# Prompt user for PHP version
default_phpversion="5.6.14"
phpversion=$default_phpversion #hard code version for now based on #24
# echo -e "\nVisit http://php.net/downloads.php for version numbers"
# echo -e "Type the version of PHP you would like (such as 5.4.42) and press [ENTER]:"
# read -e -i $default_phpversion phpversion
# phpversion=${phpversion:-$default_phpversion}

# Prompt user for MySQL password
default_mysql_root_pass=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
echo -e "\nType your desired MySQL root password"
echo -e "or leave blank for a randomly generated password and press [ENTER]:"
read -s mysql_root_pass
mysql_root_pass=${mysql_root_pass:-$default_mysql_root_pass}

# Prompt user for MW API protocol -- ASSUME HTTPS. Perhaps we'll remove this assumption later
# default_mw_api_protocol="http"
# echo -e "\nType http or https for MW API and press [ENTER]:"
# read -e -i $default_mw_api_protocol mw_api_protocol
# mw_api_protocol=${mw_api_protocol:-$default_mw_api_protocol}
mw_api_protocol=https

# Prompt user for MW API Domain or IP address
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

# Prompt user for MW install method
default_mediawiki_git_install="y"
echo -e "\nInstall MediaWiki with git? (y/n) [ENTER]:"
read -e -i $default_mediawiki_git_install mediawiki_git_install
mediawiki_git_install=${mediawiki_git_install:-$default_mediawiki_git_install}


echo ""
echo "Next you're going to setup your self-signed certificate for https."
echo "Enter values for each of the following fields. Hit any key to continue."
read -s dummy # is there another way to do this?


# generate a self-signed SSL signature (for swap-out of a good signature later, of course!)
sudo openssl req -newkey rsa:2048 -nodes -keyout /etc/pki/tls/private/meza.key -x509 -days 365 -out /etc/pki/tls/certs/meza.crt


echo "Announce completion on Slack? Enter webhook URI:"
read $slackwebhook


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
source /opt/meza/scripts/config.sh

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

	text="Your meza installation is complete"

	escapedText=$(echo $text | sed 's/"/\"/g' | sed "s/'/\'/g" )
	json="{
	    \"attachments\": [
	        {
	            \"color\": \"#339966\",
	            \"fallback\": \"Installation times\",
	            \"fields\": [
	                {
	                    \"short\": false,
	                    \"title\": \"Installation times\",
	                    \"value\": \"$cmd_times\"
	                }
	            ]
	        }
	    ],
	    \"text\": \"Your meza installation is complete\"
	}"

	curl -s -d "payload=$json" "$slackwebhook"
	echo
	echo "Message sent to Slack webhook $slackwebhook"

fi

# Display Most Plusquamperfekt Wiki Pigeon of Victory
cat "$m_meza/scripts/pigeon.txt"

