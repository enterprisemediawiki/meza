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

// get all directory names in /wikis, minus the first two: . and ..
$wikis = array_slice( scandir( "$m_htdocs/wikis" ), 2 );


if ( ! in_array( $wikiId, $wikis ) ) {

	// handle invalid wiki
	die( "No sir, I ain't heard'a no wiki that goes by the name \"$wikiId\"\n" );

}


// Get's wiki-specific config variables like:
// $wgSitename, $mezaAuthType, $mezaDebug, $mezaEnableWikiEmail
require_once "$m_htdocs/wikis/$wikiId/config/setup.php";


// https://www.mediawiki.org/wiki/Manual:$wgScriptPath
$wgScriptPath = "/$wikiId";

// https://www.mediawiki.org/wiki/Manual:$wgUploadPath
$wgUploadPath = "$wgScriptPath/img_auth.php";

// https://www.mediawiki.org/wiki/Manual:$wgUploadDirectory
$wgUploadDirectory = "$m_htdocs/wikis/$wikiId/images";

// https://www.mediawiki.org/wiki/Manual:$wgLogo
$wgLogo = "/wikis/$wikiId/config/logo.png";

// https://www.mediawiki.org/wiki/Manual:$wgFavicon
$wgFavicon = "/wikis/$wikiId/config/favicon.ico";

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

if ( $mezaEnableAllWikiEmail && isset( $mezaEnableWikiEmail ) && $mezaEnableWikiEmail ) {
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

// allows users to remove the page title.
// https://www.mediawiki.org/wiki/Manual:$wgRestrictDisplayTitle
$wgRestrictDisplayTitle = false;







/**
 *
 * Take from LocalSettingsAdditions
 *
 **/

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


$wgFileExtensions[] = 'pdf';
$wgFileExtensions[] = 'svg';
$wgUseImageMagick = true;
$wgImageMagickConvertCommand = '/usr/local/bin/convert';



/**
 * END LocalSettingsAdditions
 **/

include "$m_htdocs/__common/ComposerSettings.php";





