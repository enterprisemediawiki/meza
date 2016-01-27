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
source "$DIR/config.sh"


#
# Get admin name
#
echo -e "\nType a SAML admin full name and press [ENTER]:"
read saml_admin


#
# Get admin password
#
default_saml_password="1234"
echo -e "\nType a SAML admin password and press [ENTER]:"
read -s saml_password
saml_password=${saml_password:-$default_saml_password}


#
# Get admin email
#
echo -e "\nType a SAML admin e-mail and press [ENTER]:"
read saml_admin_email



#
# Setup identity provider
#
echo -e "\nType a SAML Identity Provider (IdP) Entity ID (can be URL) and press [ENTER]:"
read idp_entity_id

echo -e "\nType a SAML IdP sign-on URL and press [ENTER]:"
read sign_on_url

echo -e "\nType a SAML IdP logout URL and press [ENTER]:"
read logout_url

echo -e "\nType a SAML IdP certificate fingerprint and press [ENTER]:"
read cert_fingerprint

# Escape values of inputs which could have disallowed characters: / \ &
saml_admin=$(sed -e 's/[\/&]/\\&/g' <<< $saml_admin)
saml_password=$(sed -e 's/[\/&]/\\&/g' <<< $saml_password)
saml_admin_email=$(sed -e 's/[\/&]/\\&/g' <<< $saml_admin_email)
idp_entity_id=$(sed -e 's/[\/&]/\\&/g' <<< $idp_entity_id)
sign_on_url=$(sed -e 's/[\/&]/\\&/g' <<< $sign_on_url)
logout_url=$(sed -e 's/[\/&]/\\&/g' <<< $logout_url)
cert_fingerprint=$(sed -e 's/[\/&]/\\&/g' <<< $cert_fingerprint)



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
sed -i -e '/ADD SPECIAL CONFIG BELOW/r $m_meza/scripts/config/saml_httpd.conf' "$m_apache/conf/httpd.conf"

# restart apache
service httpd restart

# Setup identity provider (IdP) for SimpleSamlPHP
cd "$m_meza/simplesamlphp/metadata"
rm ./saml20-idp-remote.php
cp "$m_meza/scripts/config/saml20-idp-remote.php" ./saml20-idp-remote.php

# input correct values for your IdP
sed -r -i "s/idp_entity_id/$idp_entity_id/g;" ./saml20-idp-remote.php
sed -r -i "s/sign_on_url/$sign_on_url/g;" ./saml20-idp-remote.php
sed -r -i "s/logout_url/$logout_url/g;" ./saml20-idp-remote.php
sed -r -i "s/cert_fingerprint/$cert_fingerprint/g;" ./saml20-idp-remote.php

# Clone Extension:SimpleSamlAuth
# This would be better handled by ExtensionLoader, but for now
# I'm not going to automatically add the SimpleSamlAuth lines to
# LocalSettings.php.

echo -e "\n"

cd "$m_mediawiki/extensions"
git clone https://github.com/jornane/mwSimpleSamlAuth.git SimpleSamlAuth -b v0.6
cd SimpleSamlAuth
