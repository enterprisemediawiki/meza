#!/bin/bash
#
# Setup MediaWiki
#
# Example:
#   bash mediawiki.sh
#
#   This script will prompt the user for several parameters
#

print_title "Starting script mediawiki.sh"


#
# Prompt for parameters
#
while [ -z "$mysql_root_pass" ]
do
echo -e "\n\nEnter MySQL root password and press [ENTER]: "
read -s mysql_root_pass
done

while [ -z "$mediawiki_git_install" ]
do
echo -e "\nInstall MediaWiki with git? (y/n) [ENTER]: "
read mediawiki_git_install
done


#
# Install Composer
#
cd ~/mezadownloads
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Set the GitHub OAuth token to make use of the 5000 per hour rate limit
# Ref: https://getcomposer.org/doc/articles/troubleshooting.md#api-rate-limit-and-oauth-tokens
composer config -g github-oauth.github.com $usergithubtoken

#
# Download MediaWiki
#
cd "$m_htdocs"

if [ "$mediawiki_git_install" = "y" ]; then
	# git clone https://github.com/wikimedia/mediawiki.git wiki
	cmd_profile "START mediawiki git clone"
	git clone https://gerrit.wikimedia.org/r/p/mediawiki/core.git mediawiki
	cd mediawiki

	# Checkout latest released version
	git checkout tags/1.25.5
	cmd_profile "END mediawiki git clone"
else
	cmd_profile "START mediawiki get from tarball"
	wget http://releases.wikimedia.org/mediawiki/1.25/mediawiki-core-1.25.5.tar.gz

	mkdir mediawiki
	tar xpvf mediawiki-core-1.25.5.tar.gz -C ./mediawiki --strip-components 1
	cd mediawiki
	cmd_profile "END mediawiki get from tarball"
fi


#
# Update Composer dependencies
#
# @FIXME: This may be able to be deferred until composer-extensions
cmd_profile "START mediawiki core composer update"
composer update
cmd_profile "END mediawiki core composer update"


#
# Download Vector skin
#
cd skins

if [ "$mediawiki_git_install" = "y" ]; then
	# git clone https://github.com/wikimedia/mediawiki-skins-Vector.git Vector
	git clone https://gerrit.wikimedia.org/r/p/mediawiki/skins/Vector.git Vector
	cd Vector
	git checkout REL1_25
	cd ..
else
	wget https://github.com/wikimedia/mediawiki-skins-Vector/archive/REL1_25.tar.gz
	mkdir Vector
	tar xpvf REL1_25.tar.gz -C ./Vector --strip-components 1
fi

#
# Copy in LocalSettings.php
#
ln -s "$m_config/core/LocalSettings.php" "$m_htdocs/mediawiki/LocalSettings.php"
cp "$m_config/template/preLocalSettings_allWikis.php" "$m_config/local/preLocalSettings_allWikis.php"


#
# Add common database credentials to preLocalSettings_allWikis.php
#
echo -e "\n\n"                              >> "$m_config/local/preLocalSettings_allWikis.php"
echo "// All-wiki db user and password"     >> "$m_config/local/preLocalSettings_allWikis.php"
echo "\$wgDBuser = 'root';"                 >> "$m_config/local/preLocalSettings_allWikis.php"
echo "\$wgDBpassword = '$mysql_root_pass';" >> "$m_config/local/preLocalSettings_allWikis.php"
echo -e "\n\n"                              >> "$m_config/local/preLocalSettings_allWikis.php"

#
# Get WikiBlender
#
echo "Installing WikiBlender"
cd "$m_htdocs"
git clone https://github.com/jamesmontalvo3/WikiBlender.git
cd WikiBlender
git checkout rebaseline # use rebaseline until WikiBlender is updated
cp "$m_config/template/BlenderSettings.php" ./BlenderSettings.php

# end of script
echo -e "\n\nMediaWiki has been installed"
