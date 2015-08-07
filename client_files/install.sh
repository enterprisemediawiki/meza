#!/bin/bash
#
# Setup the entire Meza1 platform

if [ "$(whoami)" != "root" ]; then
	echo "Try running this script with sudo: \"sudo bash install.sh\""
	exit 1
fi

# If /usr/local/bin is not in PATH then add it
# Ref enterprisemediawiki/Meza1#68 "Run install.sh with non-root user"
if [[ $PATH != *"/usr/local/bin"* ]]; then
	PATH="/usr/local/bin:$PATH"
fi

echo -e "\nWelcome to Meza1 v0.2.1\n"

#
# Set architecture to 32 or 64 (bit)
#
if [ $(uname -m | grep -c 64) -eq 1 ]; then
architecture=64
else
architecture=32
fi


# if the script was called in the form:
# bash install <architecture> \
#              <phpversion> \
#              <mysql_root_pass> \
#              <wiki_db_name> \
#              <wiki_name> \
#              <wiki_admin_name> \
#              <wiki_admin_pass>
# then set params accordingly (meaning no user interaction required)
#
# These are out of hand. Change them to GNU-style long-options, see:
# http://mywiki.wooledge.org/BashFAQ/035
if [ ! -z "$1" ]; then
    phpversion="$1"
fi

if [ ! -z "$2" ]; then
    mysql_root_pass="$2"
fi

if [ ! -z "$3" ]; then
    wiki_db_name="$3"
fi

if [ ! -z "$4" ]; then
    wiki_name="$4"
fi

if [ ! -z "$5" ]; then
    wiki_admin_name="$5"
fi

if [ ! -z "$6" ]; then
    wiki_admin_pass="$6"
fi

if [ ! -z "$7" ]; then
    git_branch="$7"
fi

if [ ! -z "$8" ]; then
    mw_api_protocol="$8"
fi

if [ ! -z "$9" ]; then
    mw_api_domain="$9"
fi


# Prompt user for PHP version
while [ -z "$phpversion" ]
do
echo -e "\nVisit http://php.net/downloads.php for version numbers"
echo -e "Enter version of PHP you would like (such as 5.4.42) and press [ENTER]: "
read phpversion
done

while [ -z "$mysql_root_pass" ]
do
echo -e "\nEnter MySQL root password and press [ENTER]: "
read -s mysql_root_pass
done

while [ -z "$wiki_db_name" ]
do
echo -e "\nEnter desired name of your wiki database and press [ENTER]: "
read wiki_db_name
done

while [ -z "$wiki_name" ]
do
echo -e "\nEnter desired name of your wiki and press [ENTER]: "
read wiki_name
done

while [ -z "$wiki_admin_name" ]
do
echo -e "\nEnter desired administrator account username and press [ENTER]: "
read wiki_admin_name
done

while [ -z "$wiki_admin_pass" ]
do
echo -e "\nEnter password you would like for your wiki administrator account and press [ENTER]: "
read -s wiki_admin_pass
done

while [ -z "$git_branch" ]
do
echo -e "\nEnter git branch of Meza1 you want to use (generally this is \"master\") [ENTER]: "
read git_branch
done

while [ "$mw_api_protocol" != "http" ] && [ "$mw_api_protocol" != "https" ]
do
echo -e "\nType http or https for MW API and press [ENTER]: "
read mw_api_protocol
done

while [ -z "$mw_api_domain" ]
do
echo -e "\nType domain or IP address of your wiki and press [ENTER]: "
read mw_api_domain
done

while [ -z "$mediawiki_git_install" ]
do
echo -e "\nInstall MediaWiki with git? (y/n) [ENTER]: "
read mediawiki_git_install
done


# Check if git installed, and install it if required
if ! hash git 2>/dev/null; then
    echo "************ git not installed, installing ************"
    yum install git -y
fi

# if no sources directory, create it
if [ ! -d ~/sources ]; then
	mkdir ~/sources
fi


#
# Output command to screen and to log files
#
timestamp=$(date "+%Y%m%d%H%M%S")
logpath="/root/sources/meza1/logs"
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
# command_to_screen_and_logs "bash yums.sh $architecture || exit 1"
cmd_tee()
{
	cmd_profile "START $*"
	$@ > >(tee -a "$outlog") 2> >(tee -a "$errlog" >&2)
	sleep 1 # why is this needed? It is needed, but why?
	cmd_profile "END $*"
}

# function to install Meza1 via git
install_via_git()
{
	cd ~/sources
	git clone https://github.com/enterprisemediawiki/Meza1 meza1
	cd meza1
	git checkout "$git_branch"
}

# no meza1 directory
if [ ! -d ~/sources/meza1 ]; then
	install_via_git

# meza1 exists, but is not a git repo (hold over from older versions of meza1)
elif [ ! -d ~/sources/meza1/.git ]; then
	rm -rf ~/sources/meza1
	install_via_git

# meza1 exists and is a git repo: checkout latest branch
else
	cd ~/sources/meza1
	git fetch origin
	git checkout "$git_branch"
fi

cd ~/sources/meza1/client_files
cmd_tee "source yums.sh || exit 1"

cd ~/sources/meza1/client_files
cmd_tee "source apache.sh || exit 1"

cd ~/sources/meza1/client_files
cmd_tee "source php.sh || exit 1"

cd ~/sources/meza1/client_files
cmd_tee "source mysql.sh || exit 1"

cd ~/sources/meza1/client_files
cmd_tee "source mediawiki.sh || exit 1"

cd ~/sources/meza1/client_files
cmd_tee "source extensions.sh || exit 1"

cd ~/sources/meza1/client_files
cmd_tee "source VE.sh || exit 1"

cd ~/sources/meza1/client_files
cmd_tee "source ElasticSearch.sh || exit 1"


# Display Most Plusquamperfekt Wiki Pigeon of Victory
cat ~/sources/meza1/client_files/pigeon.txt

