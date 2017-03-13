#!/bin/sh
#
# Setup SAML authentication for MediaWiki


if [ "$(whoami)" != "root" ]; then
        echo "Try running this script with sudo: \"sudo bash install.sh\""
        exit 1
fi

# If /usr/local/bin is not in PATH then add it
# Ref enterprisemediawiki/meza#68 "Run install.sh with non-root user"
if [[ $PATH != *"/usr/local/bin"* ]]; then
        PATH="/usr/local/bin:$PATH"
fi


#
# For now this script is not called within the same shell as install.sh
# and thus it needs to know how to get to the config.sh script on it's own
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "/opt/meza/config/core/config.sh"


if [ -f "$m_config/local/saml-setup-config.sh" ]; then
	source "$m_config/local/saml-setup-config.sh"
fi

#
# Get admin name
#
if [ -z "$saml_admin" ]; then
	echo -e "\nType a SAML admin full name and press [ENTER]:"
	read saml_admin
fi


#
# Get admin password
#
default_saml_password="1234"
if [ -z "$saml_password" ]; then
	echo -e "\nType a SAML admin password and press [ENTER]:"
	read -s saml_password
	saml_password=${saml_password:-$default_saml_password}
fi


#
# Get admin email
#
if [ -z "$saml_admin_email" ]; then
	echo -e "\nType a SAML admin e-mail and press [ENTER]:"
	read saml_admin_email
fi


#
# Setup identity provider and service provider
#
if [ -z "$idp_entity_id" ]; then
	echo -e "\nIdentity Provider (IdP) then [ENTER]:"
	echo -e "Ex: Probably your identity provider's URL, like https://id.example.com"
	read idp_entity_id
fi

if [ -z "$sign_on_url" ]; then
	echo -e "\nIdP sign-on URL then [ENTER]:"
	read sign_on_url
fi


if [ -z "$logout_url" ]; then
	echo -e "\nIdP logout URL then [ENTER]:"
	read logout_url
fi

if [ -z "$cert_fingerprint" ]; then
	echo -e "\nIdP certificate fingerprint then [ENTER]:"
	read cert_fingerprint
fi


if [ -z "$sp_entity_id" ]; then
	echo -e "\nService Provider (SP) entity ID then [ENTER]:"
	echo -e "Ex: Probably your application's URL, like https://myapp.example.com"
	read sp_entity_id
fi

if [ -z "$name_id_policy" ]; then
	echo -e "\nName-ID Policy then [ENTER]:"
	echo -e "Ex: urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
	read name_id_policy
fi


if [ -z "$username_attr" ]; then
	echo -e "\nSAML attribute name to map to MediaWiki username then [ENTER]:"
	read username_attr
fi


if [ -z "$realname_attr" ]; then
	echo -e "\nSAML attribute name to map to MediaWiki realname then [ENTER]:"
	read realname_attr
fi


if [ -z "$email_attr" ]; then
	echo -e "\nSAML attribute name to map to MediaWiki e-mail then [ENTER]:"
	read email_attr
fi


# Escape values of inputs which could have disallowed characters: / \ &
saml_admin=$(sed -e 's/[\/&]/\\&/g' <<< $saml_admin)
saml_password=$(sed -e 's/[\/&]/\\&/g' <<< $saml_password)
saml_admin_email=$(sed -e 's/[\/&]/\\&/g' <<< $saml_admin_email)
idp_entity_id=$(sed -e 's/[\/&]/\\&/g' <<< $idp_entity_id)
sign_on_url=$(sed -e 's/[\/&]/\\&/g' <<< $sign_on_url)
logout_url=$(sed -e 's/[\/&]/\\&/g' <<< $logout_url)
cert_fingerprint=$(sed -e 's/[\/&]/\\&/g' <<< $cert_fingerprint)
sp_entity_id=$(sed -e 's/[\/&]/\\&/g' <<< $sp_entity_id)
name_id_policy=$(sed -e 's/[\/&]/\\&/g' <<< $name_id_policy)
username_attr=$(sed -e 's/[\/&]/\\&/g' <<< $username_attr)
realname_attr=$(sed -e 's/[\/&]/\\&/g' <<< $realname_attr)
email_attr=$(sed -e 's/[\/&]/\\&/g' <<< $email_attr)


echo -e "\n"



# install simplesamlphp from github
# See https://simplesamlphp.org/docs/development/simplesamlphp-install-repo
cd "$m_meza"
git clone https://github.com/simplesamlphp/simplesamlphp.git simplesamlphp
cd simplesamlphp
cp -r config-templates/* config/
cp -r metadata-templates/* metadata/
composer install

cd config

# generate a crypto salt and insert into config.php
salt=$(tr -c -d '0123456789abcdefghijklmnopqrstuvwxyz' </dev/urandom | dd bs=32 count=1 2>/dev/null;echo)
sed -r -i "s/'secretsalt'.*$/'secretsalt' => '$salt',/g;" ./config.php

# add password, name, and email to config.php
sed -r -i "s/'auth.adminpassword'.*$/'auth.adminpassword' => '$saml_password',/g;" ./config.php
sed -r -i "s/'technicalcontact_name'.*$/'technicalcontact_name' => '$saml_admin',/g;" ./config.php
sed -r -i "s/'technicalcontact_email'.*$/'technicalcontact_email' => '$saml_admin_email',/g;" ./config.php


# Add SimpleSamlPhp alias directive to Apache httpd.conf
# This inserts the contents of one file (saml_httpd.conf) below a marker
# in httpd.conf. See link below for more info:
# http://unix.stackexchange.com/questions/32908/how-to-insert-the-content-of-a-file-into-another-file-before-a-pattern-marker
# FIXME: httpd.conf should not be modified
sed -i -e "/ADD SPECIAL CONFIG BELOW/r $m_config/core/template/saml_httpd.conf" "$m_config/core/httpd.conf"

# restart apache
service httpd restart

# Setup identity provider (IdP) for SimpleSamlPHP
cd "$m_meza/simplesamlphp/metadata"
rm ./saml20-idp-remote.php
cp "$m_config/core/template/saml20-idp-remote.php" "$m_config/local/saml20-idp-remote.php"
ln -s "$m_config/local/saml20-idp-remote.php" "$m_meza/simplesamlphp/metadata/saml20-idp-remote.php"

# input correct values for your IdP
cd "$m_config/local"
sed -r -i "s/idp_entity_id/$idp_entity_id/g;" ./saml20-idp-remote.php
sed -r -i "s/sign_on_url/$sign_on_url/g;" ./saml20-idp-remote.php
sed -r -i "s/logout_url/$logout_url/g;" ./saml20-idp-remote.php
sed -r -i "s/cert_fingerprint/$cert_fingerprint/g;" ./saml20-idp-remote.php


# Setup authsources.php
cd "$m_config/local"
mv "$m_meza/simplesamlphp/config/authsources.php" ./simplesaml_authsources.php
sed -r -i "s/'entityID' => null,/'entityID' => '$sp_entity_id',\n\t'NameIDPolicy' => '$name_id_policy',\n/g;" ./simplesaml_authsources.php
sed -r -i "s/'idp' => null,/'idp' => '$idp_entity_id',/g;" ./simplesaml_authsources.php
ln -s "$m_config/local/simplesaml_authsources.php" "$m_meza/simplesamlphp/config/authsources.php"


echo -e "\n"

# Clone Extension:SimpleSamlAuth
# Could use ExtensionLoader to load this here, which in many ways would be better,
# but it would also mean we'd have to set WIKI=something, and what would that be?
# It could be "demo", but wiki_demo could be removed. This is easier for now.
cd "$m_mediawiki/extensions"
git clone https://github.com/jornane/mwSimpleSamlAuth.git SimpleSamlAuth -b v0.6

# Create a local SAML config file from template file. This file will be used by
# both MediaWiki (all wikis) and the landing page (and possibly other things in
# the future). MediaWiki will be aware of this file because it will be required
# from within SAML-postLocalSettings.php (see below).
cp "$m_config/core/template/SAMLConfig.php" "$m_config/local/SAMLConfig.php"

# Replace attributes with user input
sed -r -i "s/username_attr/$username_attr/g;" "$m_config/local/SAMLConfig.php"
sed -r -i "s/realname_attr/$realname_attr/g;" "$m_config/local/SAMLConfig.php"
sed -r -i "s/email_attr/$email_attr/g;" "$m_config/local/SAMLConfig.php"

# Create a postLocalSettings_allWikis.php if it doesn't exist
if [ ! -f "$m_config/local/postLocalSettings_allWikis.php" ]; then
    echo -e "<?php\n\n" > "$m_config/local/postLocalSettings_allWikis.php"
fi

# Add SAML-specific settings to postLocalSettings_allWikis.php
cat "$m_config/core/template/SAML-postLocalSettings.php" >> "$m_config/local/postLocalSettings_allWikis.php";

# Add these lines to the bottom of preLocalSettings_allWikis.php, then remove the temp file
# these disable account creation for users
if [ ! -f "$m_config/local/preLocalSettings_allWikis.php" ]; then
    echo -e "<?php\n\n" > "$m_config/local/preLocalSettings_allWikis.php"
fi
cat "$m_config/core/template/SAML-preLocalSettings.php" >> "$m_config/local/preLocalSettings_allWikis.php";


echo "Complete with SAML setup"
