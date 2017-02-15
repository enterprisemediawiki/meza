#!/bin/bash
#
# Setup MediaWiki


#
# Install Composer
#
cd /tmp
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
	git checkout tags/1.27.1
	cmd_profile "END mediawiki git clone"
else
	cmd_profile "START mediawiki get from tarball"
	wget http://releases.wikimedia.org/mediawiki/1.27/mediawiki-core-1.27.1.tar.gz

	mkdir mediawiki
	tar xpvf mediawiki-core-1.27.1.tar.gz -C ./mediawiki --strip-components 1
	cd mediawiki
	cmd_profile "END mediawiki get from tarball"
fi


# Hotfix
#
# Before composer-merge-plugin v1.2.0, MW incorrectly required
# v1.0.0 of the Composer internal composer-plugin-api component.
# Composer recently bumped this internal version to v1.1.0 [0].
# A patch to MW is in work, but this is required to keep meza
# building properly.
#
# [0]: https://github.com/composer/composer/commit/aeafe2fe59992efd1bc3f890b760f1a9c4874e1c
#
# Replace v1.0.0 with v1.3.1 of wikimedia/composer-merge-plugin in composer.json
sed -r -i 's/"wikimedia\/composer-merge-plugin": "1.0.0",/"wikimedia\/composer-merge-plugin": "1.3.1",/;' "$m_mediawiki/composer.json"


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
	git checkout REL1_27
	cd ..
else
	wget https://github.com/wikimedia/mediawiki-skins-Vector/archive/REL1_27.tar.gz
	mkdir Vector
	tar xpvf REL1_27.tar.gz -C ./Vector --strip-components 1
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

mezaDatabasePassword
echo "\$mezaDatabaseServers = '$db_server_ips';" >> "$m_config/local/preLocalSettings_allWikis.php"
echo "\$mezaDatabasePassword = '$db_password';" >> "$m_config/local/preLocalSettings_allWikis.php"
echo -e "\n\n"                              >> "$m_config/local/preLocalSettings_allWikis.php"


#
# Get WikiBlender
#
echo "Installing WikiBlender"
cd "$m_htdocs"
git clone https://github.com/jamesmontalvo3/WikiBlender.git
cd WikiBlender
ln -s "$m_config/core/BlenderSettings.php" ./BlenderSettings.php
cp "$m_config/template/LandingPage.php" "$m_config/local/LandingPage.php"


# end of script
echo -e "\n\nMediaWiki has been installed"
