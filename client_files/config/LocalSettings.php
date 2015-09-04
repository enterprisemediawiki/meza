<?php
# This is the main configuration settings for all Meza1 wikis. This file
# should not be edited. Instead edit TBD. @todo @fixme

# Protect against web entry
if ( !defined( 'MEDIAWIKI' ) ) {
        exit;
}

// same value as bash variable in config.sh
$m_htdocs = '/var/www/meza1/htdocs';

require_once "$m_htdocs/__common/AllWikiSettings.php";

if( $wgCommandLineMode ) {

	$mezaWikiEnvVarName='WIKI';

	// get $wikiId from environment variable
	$wikiId = getenv( $mezaWikiEnvVarName );

}
else {

	// get $wikiId from URI
	$uriParts = explode( '/', $_SERVER['REQUEST_URI'] );
	$wikiId = strtolower( $uriParts[1] ); // URI has leading slash, so $uriParts[0] is empty string

}

// for now just a dummy list of wikis
$wikis = array( 'eva', 'oso', 'robo' );


if ( ! in_array( $wikiId, $wikis ) ) {

	// handle invalid wiki
	die( "No sir, I ain't heard'a no wiki that goes by the name \"$wikiId\"" );

}


// Path of to images and config for this $wikiId
$mezaWikiIP = "/wikis/$wikiId";

// Get's wiki-specific config variables like:
// $wgSitename, $mezaAuthType, $mezaDebug, $mezaEnableWikiEmail
require_once "$mezaWikiIP/config/setup.php";


// https://www.mediawiki.org/wiki/Manual:$wgScriptPath
$wgScriptPath = "/$wikiId";

// https://www.mediawiki.org/wiki/Manual:$wgUploadPath
$wgUploadPath = "$mezaWikiIP/images";

// https://www.mediawiki.org/wiki/Manual:$wgUploadDirectory
$wgUploadDirectory = "$m_htdocs/wikis/$wikiId/images";

// https://www.mediawiki.org/wiki/Manual:$wgLogo
$wgLogo = "$mezaWikiIP/config/logo.png";

// https://www.mediawiki.org/wiki/Manual:$wgEmergencyContact
$wgEmergencyContact = "enterprisemediawiki@gmail.com"; // @todo: this should be in setup, but this is easier for now.

// https://www.mediawiki.org/wiki/Manual:$wgPasswordSender
$wgPasswordSender = "enterprisemediawiki@gmail.com"; // @todo: this should be in setup, but this is easier for now.

// https://www.mediawiki.org/wiki/Manual:$wgMetaNamespace
$wgMetaNamespace = str_replace( ' ', '_', $wgSitename );

// @todo: handle auth type from setup.php
// @todo: handle debug from setup.php

// From MW web install: Uncomment this to disable output compression
# $wgDisableOutputCompression = true;

$wgScriptExtension = ".php";

## The relative URL path to the skins directory
$wgStylePath = "$wgScriptPath/skins";
$wgResourceBasePath = $wgScriptPath;

if ( $mezaAllWikiEmail && isset( $mezaEnableWikiEmail ) && $mezaEnableWikiEmail ) {
	$wgEnableEmail = true;
}
else {
	$wgEnableEmail = false;
}

## UPO means: this is also a user preference option
$wgEnableUserEmail = $wgEnableEmail; # UPO
$wgEnotifUserTalk = false; # UPO
$wgEnotifWatchlist = false; # UPO
$wgEmailAuthentication = true;


## Database settings
$wgDBtype = "mysql";
$wgDBserver = "";
if ( isset( $mezaCustomDBname ) ) {
	$wgDBname = $mezaCustomDBname;
} else {
	$wgDBname = "wiki_$wikiId";
}
if ( isset( $mezaCustomDBuser ) && isset ( $mezaCustomDBpass ) ) {
	$wgDBuser = $mezaCustomDBuser;
	$wgDBpassword = $mezaCustomDBpass;
} else {
	require_once "$m_htdocs/__common/dbUserPass.php";
}

# MySQL specific settings
$wgDBprefix = "";

# MySQL table options to use during installation or update
$wgDBTableOptions = "ENGINE=InnoDB, DEFAULT CHARSET=binary";

# Experimental charset support for MySQL 5.0.
$wgDBmysql5 = false;

## Shared memory settings
$wgMainCacheType = CACHE_NONE;
$wgMemCachedServers = array();

## To enable image uploads, make sure the 'images' directory
## is writable, then set this to true:
$wgEnableUploads = true;
$wgMaxUploadSize = 1024*1024*100; // 100 MB
$wgUseImageMagick = true;
$wgImageMagickConvertCommand = "/usr/bin/convert";

# InstantCommons allows wiki to use images from http://commons.wikimedia.org
$wgUseInstantCommons = false;

## If you use ImageMagick (or any other shell command) on a
## Linux server, this will need to be set to the name of an
## available UTF-8 locale
$wgShellLocale = "en_US.utf8";

## If you want to use image uploads under safe mode,
## create the directories images/archive, images/thumb and
## images/temp, and make them all writable. Then uncomment
## this, if it's not already uncommented:
$wgHashedUploadDirectory = true;

## Set $wgCacheDirectory to a writable directory on the web server
## to make your wiki go slightly faster. The directory should not
## be publically accessible from the web.
#$wgCacheDirectory = "$IP/cache";

# Site language code, should be one of the list in ./languages/Names.php
$wgLanguageCode = "en";

/**
 * @todo: figure out what to do with these.
 * These should be moved out of this file and generated randomly for each
 * install. Either that, or they should be removed entirely since they
 * appear not to be used post MW v1.17.
 **/
$wgSecretKey = "h950ac53h622q0shtr0aSDh743y534yae68i8745436hl29iu48974safgd435o6";
# Site upgrade key. Must be set to a string (default provided) to turn on the
# web installer while LocalSettings.php is in place
$wgUpgradeKey = "8w456u657946rw45";

## For attaching licensing metadata to pages, and displaying an
## appropriate copyright notice / icon. GNU Free Documentation
## License and Creative Commons licenses are supported so far.
$wgRightsPage = ""; # Set to the title of a wiki page that describes your license/copyright
$wgRightsUrl = "";
$wgRightsText = "";
$wgRightsIcon = "";

# Path to the GNU diff3 utility. Used for conflict resolution.
$wgDiff3 = "/usr/bin/diff3";

## Default skin: you can change the default skin. Use the internal symbolic
## names, ie 'vector', 'monobook':
$wgDefaultSkin = "vector";

# Enabled skins.
# The following skins were automatically enabled:
wfLoadSkin( 'Vector' );


# End of automatically generated settings.
# Add more configuration options below.


enableSemantics( "Meza1.$wikiId" );

// SMW Settings Overrides:
$smwgQMaxSize = 5000;

$srfgFormats = array(
        'calendar',
        'timeline',
        'filtered',
        //'exhibit',
        'eventline',
        'tree',
        'oltree',
        'datatables',
        'ultree',
        'tagcloud',
        'sum',
        'pagewidget'
);

// allows adding semantic properties to Templates themselves
// (not just on pages via templates).
// ENABLE THIS AFTER ALL TEMPLATES HAVE BEEN CHECKED FOR PROPER FORM
// i.e. using <noinclude> and <includeonly> properly
// $smwgNamespacesWithSemanticLinks[NS_TEMPLATE] = true;
$smwgNamespacesWithSemanticLinks[NS_TALK] = true;


// opens external links in new window
$wgExternalLinkTarget = '_blank';

// added this line to allow linking. specifically to Imagery Online.
$wgAllowExternalImages = true;
$wgAllowImageTag = true;

$wgVectorUseSimpleSearch = true;

//$wgDefaultUserOptions['useeditwarning'] = 1;

// disable page edit warning (edit warning affect Semantic Forms)
$wgVectorFeatures['editwarning']['global'] = false;

$wgDefaultUserOptions['rememberpassword'] = 1;

// users watch pages by default (they can override in settings)
$wgDefaultUserOptions['watchdefault'] = 1;
$wgDefaultUserOptions['watchmoves'] = 1;
$wgDefaultUserOptions['watchdeletion'] = 1;
$wgDefaultUserOptions['watchcreations'] = 1;

$wgEnableMWSuggest = true;

// fixes login issue for some users (login issue fixed in MW version 1.18.1 supposedly)
$wgDisableCookieCheck = true;

#Set Default Timezone
$wgLocaltimezone = "America/Chicago";
$oldtz = getenv("TZ");
putenv("TZ=$wgLocaltimezone");


$wgFileExtensions[] = 'mp3';
$wgFileExtensions[] = 'aac';
$wgFileExtensions[] = 'msg';

$wgMaxImageArea = 1.25e10; // Images on [[Snorkel]] fail without this
// $wgMemoryLimit = 500000000; //Default is 50M. This is 500M.


// Increase from default setting for large form
// See https://www.mediawiki.org/wiki/Extension_talk:Semantic_Forms/Archive_April_to_June_2012#Error:_Backtrace_limit_exceeded_during_parsing
// If set to 10million, errors are seen when using Edit with form on mission pages like 41S
// ini_set( 'pcre.backtrack_limit', 10000000 ); //10million
ini_set( 'pcre.backtrack_limit', 1000000000 ); //1 billion

/**
 *  Code to load the extension "ExtensionLoader", which then installs and loads
 *  other extensions as defined in "ExtensionSettings.php". Note that the file
 *  or files defining which extensions are loaded is configurable below, as is
 *  the path to where extensions are installed.
 */
require_once "$IP/extensions/ExtensionLoader/ExtensionLoader.php";
ExtensionLoader::init( "$IP/ExtensionSettings.php" );
foreach( ExtensionLoader::$loader->oldExtensions as $extensionPath ) {
        require_once $extensionPath;
}
ExtensionLoader::$loader->completeExtensionLoading();

/*

THIS IS ALL STUFF THAT SHOULD BE INCLUDED HERE DIRECTLY, BUT FOR NOW IS ADDED
`VE.sh` AND `ElasticSearch.sh` INSTEAD. BASICALLY THIS SHOULD ALL, BY THE END
OF INSTALL, BE DUPLICATED AT THE END OF THIS DOCUMENT, BUT IN A NOT-COMMENTED
OUT FORM.

// ******* Begin info for VE *******

// Enable by default for everybody
$wgDefaultUserOptions['visualeditor-enable'] = 1;

// Don't allow users to disable it
$wgHiddenPrefs[] = 'visualeditor-enable';

// OPTIONAL: Enable VisualEditor's experimental code features
#$wgDefaultUserOptions['visualeditor-enable-experimental'] = 1;

// URL to the Parsoid instance
// MUST NOT end in a slash due to Parsoid bug
// Use port 8142 if you use the Debian package
$wgVisualEditorParsoidURL = 'http://127.0.0.1:8000';

// Interwiki prefix to pass to the Parsoid instance
// Parsoid will be called as $url/$prefix/$pagename
$wgVisualEditorParsoidPrefix = 'wiki';

// ******* End info for VE *******

// ******* Begin info for Elastic Search *******

//$wgCirrusSearchServers = array( 'search01', 'search02' );
$wgSearchType = "CirrusSearch";

// ******* End info for Elastic Search *******
*/

