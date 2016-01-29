#
# Extension:SimpleSamlAuth
#
require_once $egExtensionLoader->registerLegacyExtension(
	'SimpleSamlAuth',
	'https://github.com/jornane/mwSimpleSamlAuth.git',
	'tags/v0.6'
);

// make sure that session storage matches to the one used in simplesaml most likely default PHPSESSID
$wgSessionName = "PHPSESSID";

// SAML_OPTIONAL // SAML_LOGIN_ONLY // SAML_REQUIRED
$wgSamlRequirement = SAML_REQUIRED;

// Should users be created if they don't exist in the database yet?
$wgSamlCreateUser = true;

// SAML attributes
$wgSamlUsernameAttr = 'username_attr';
$wgSamlRealnameAttr = 'realname_attr';
$wgSamlMailAttr = 'email_attr';

// SimpleSamlPhp settings
$wgSamlSspRoot = '/opt/meza/simplesamlphp';
$wgSamlAuthSource = 'default-sp';
$wgSamlPostLogoutRedirect = NULL;

// Array: [MediaWiki group][SAML attribute name][SAML expected value]
// If the SAML assertion matches, the user is added to the MediaWiki group
$wgSamlGroupMap = array(
	//'sysop' => array(
	//	'groups' => array('admin'),
	//),
);