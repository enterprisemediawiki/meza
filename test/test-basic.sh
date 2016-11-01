#!/bin/sh
#
# "Automate" testing. But not really. Just do as much automatically as possible.


# must be root or sudoer
if [ "$(whoami)" != "root" ]; then
	echo "Try running this script with sudo: \"sudo bash import-wiki.sh\""
	exit 1
fi


# If /usr/local/bin is not in PATH then add it
# Ref enterprisemediawiki/meza#68 "Run install.sh with non-root user"
if [[ $PATH != *"/usr/local/bin"* ]]; then
	PATH="/usr/local/bin:$PATH"
fi


# Get config
source "/opt/meza/config/core/config.sh"


# prompt user for MySQL root password
while [ -z "$mysql_root_pass" ]
do
echo -e "\nEnter MySQL root password and press [ENTER]: "
read -s mysql_root_pass
done


# Turn on debug
sed -r -i 's/mezaForceDebug = false/mezaForceDebug = true/g;' "$m_config/core/LocalSettings.php"


# Create a wiki
imports_dir=new
wiki_id=test_created_wiki
wiki_name="Test Created Wiki"
slackwebhook=n
source "$m_scripts/create-wiki.sh"


# Import a test wiki
cd /tmp
git clone "https://github.com/enterprisemediawiki/meza-test-cases"
imports_dir="/tmp/meza-test-cases/wikis"
source "$m_scripts/import-wikis.sh"
