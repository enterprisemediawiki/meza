<?php

// make sure that session storage matches to the one used in simplesaml most likely default PHPSESSID
$wgSessionName = "PHPSESSID";

// SAML_OPTIONAL // SAML_LOGIN_ONLY // SAML_REQUIRED
$wgSamlRequirement = SAML_REQUIRED;

// Should users be created if they don't exist in the database yet?
$wgSamlCreateUser = true;

// SAML attributes. These are edited by /opt/meza/scripts/saml.sh
// when setting up SAML auth.
$wgSamlUsernameAttr = 'username_attr';
$wgSamlRealnameAttr = 'realname_attr';
$wgSamlMailAttr = 'email_attr';

// SimpleSamlPhp settings
$wgSamlSspRoot = '/opt/meza/simplesamlphp';
$wgSamlAuthSource = 'default-sp';
$wgSamlPostLogoutRedirect = NULL;
