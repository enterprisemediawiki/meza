#!/bin/bash
#
# Prompts for install.sh

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


# Prompt user for MySQL password
default_mysql_root_pass=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
echo -e "\nType your desired MySQL root password"
echo -e "or leave blank for a randomly generated password and press [ENTER]:"
read -s mysql_root_pass
mysql_root_pass=${mysql_root_pass:-$default_mysql_root_pass}

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
openssl req -newkey rsa:4096 -nodes -keyout /etc/pki/tls/private/meza.key -x509 -days 365 -out /etc/pki/tls/certs/meza.crt

echo
echo
echo "Announce completion on Slack?"
echo "Enter webhook URI or leave blank to opt out:"
read slackwebhook

if [[ -z "$slackwebhook" ]]; then
	slackwebhook="n"
fi