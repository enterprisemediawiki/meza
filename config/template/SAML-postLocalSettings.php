#
# Extension:SimpleSamlAuth
#
# Only do auth on requests from outside the server. Requests from inside are a
# service...probably Parsoid
# Ref: https://www.mediawiki.org/wiki/Talk:Parsoid/Archive#Running_Parsoid_on_a_.22private.22_wiki_-_AccessDeniedError
# Ref: https://www.mediawiki.org/wiki/Extension:VisualEditor#Linking_with_Parsoid_in_private_wikis
$samlRemoteAddrCheck = isset( $_SERVER['REMOTE_ADDR'] ) ? $_SERVER['REMOTE_ADDR'] : '';
$samlServerAddrCheck = isset( $_SERVER['SERVER_ADDR'] ) ? $_SERVER['SERVER_ADDR'] : '';
if ( $samlRemoteAddrCheck !== $samlServerAddrCheck ) {


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

	$GLOBALS['wgHooks']['SpecialPage_initList'][] = function (&$list) {
		unset( $list['Userlogout'] );
		unset( $list['Userlogin'] );
		return true;
	};

	$GLOBALS['wgHooks']['PersonalUrls'][] = function (&$personal_urls, &$wgTitle) {
		unset( $personal_urls["login"] );
		unset( $personal_urls["logout"] );
		unset( $personal_urls['anonlogin'] );
		return true;
	};

}
