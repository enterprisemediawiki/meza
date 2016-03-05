<?php

# Protect against web entry
if ( !defined( 'MEDIAWIKI' ) ) {
	exit;
}


/**
 *  TABLE OF CONTENTS
 *
 *    1) WIKI-SPECIFIC SETUP
 *    2) DEBUG
 *    3) PATH SETUP
 *    4) EMAIL
 *    5) DATABASE SETUP
 *    6) GENERAL CONFIGURATION
 *    7) EXTENSION SETTINGS
 *    8) PERMISSIONS
 *    9) LOAD OVERRIDES
 *
 **/



/**
 *  1) WIKI-SPECIFIC SETUP
 *
 *  Acquire the intended wiki either from the REQUEST_URI (for web requests) or
 *  from the WIKI environment variable (for command line scripts)
 **/

// same value as bash variable in config.sh
$m_meza = '/opt/meza';
$m_config = $m_meza . '/config';
$m_htdocs = $m_meza . '/htdocs';

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

// Load all-wikis setup.php first, then allow wiki-specific setup.php to modify
require_once "$m_config/local/setup.php";

// Gets wiki-specific config variables like:
// $wgSitename, $mezaAuthType, $mezaDebug, $mezaEnableWikiEmail
require_once "$m_htdocs/wikis/$wikiId/config/setup.php";






/**
 *  2) DEBUG
 *
 *  Options to enable debug are below. The lowest-impact solution should be
 *  chosen. Options are listed from least impact to most impact.
 *    1) Add to the URI you're requesting `requestDebug=true` to enable debug
 *       for just that request.
 *    2) Set `$mezaCommandLineDebug = true;` for debug on the command line.
 *       This is the default, which can be overriden in setup.php.
 *    3) Set `$mezaDebug = array( "NDC\Your-ndc", ... );` in a wiki's setup.php
 *       to enable debug for just specific users on a single wiki.
 *    4) Set `$mezaDebug = true;` in a wiki's setup.php to enable debug for all
 *       users of a single wiki.
 *    5) Set `$mezaForceDebug = true;` to turn on debug for all users and wikis
 **/
$mezaCommandLineDebug = true; // don't we always want debug on command line?
$mezaForceDebug = false;


if ( $mezaForceDebug ) {
	$debug = true;
}

elseif ( $wgCommandLineMode && $mezaCommandLineDebug ) {
	$debug = true;
}

elseif ( $GLOBALS['mezaDebug'] === true ) {
	$debug = true;
}

// Check if $mezaDebug is an array, and if so check if the requesting user is
// in the array.
elseif ( ! $wgCommandLineMode
	&& is_array( $GLOBALS['mezaDebug'] )
	&& in_array( $_SERVER["REMOTE_USER"], $GLOBALS['mezaDebug'] )
) {
	$debug = true;
}

elseif ( isset( $_GET['requestDebug'] ) ) {
	$debug = true;
}

else {
	$debug = false;
}


if ( $debug ) {

	// turn error logging on
	error_reporting( -1 );
	ini_set( 'display_errors', 1 );
	ini_set( 'log_errors', 1 );

	// Output errors to log file
	ini_set( 'error_log', __DIR__ . '/php.log' );

	// MediaWiki Debug Tools
	$wgShowExceptionDetails = true;
	$wgDebugToolbar = true;
	$wgShowDebug = true;

}

// production: no error reporting
else {

	error_reporting(0);
	ini_set("display_errors", 0);

}










/**
 *  3) PATH SETUP
 *
 *
 **/

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









/**
 *  4) EMAIL
 *
 *  Email configuration
 **/
if ( $mezaEnableAllWikiEmail && isset( $mezaEnableWikiEmail ) && $mezaEnableWikiEmail ) {
	$wgEnableEmail = true;
}
else {
	$wgEnableEmail = false;
}

## UPO means: this is also a user preference option
$wgEnableUserEmail = $wgEnableEmail; # UPO
$wgEnotifUserTalk = $wgEnableEmail; # UPO
$wgEnotifWatchlist = $wgEnableEmail; # UPO
$wgEmailAuthentication = $wgEnableEmail;










/**
 *  5) DATABASE SETUP
 *
 *
 **/
$wgDBtype = "mysql";
$wgDBserver = "";
if ( isset( $mezaCustomDBname ) ) {
	$wgDBname = $mezaCustomDBname;
} else {
	$wgDBname = "wiki_$wikiId";
}

// Custom database user and password, if any wikis have that (none do now)
if ( isset( $mezaCustomDBuser ) && isset ( $mezaCustomDBpass ) ) {
	$wgDBuser = $mezaCustomDBuser;
	$wgDBpassword = $mezaCustomDBpass;
}

# MySQL specific settings
$wgDBprefix = "";

# MySQL table options to use during installation or update
$wgDBTableOptions = "ENGINE=InnoDB, DEFAULT CHARSET=binary";

# Experimental charset support for MySQL 5.0.
$wgDBmysql5 = false;

/**
 *  If a primewiki is defined then every wiki will use that wiki db for certain
 *  tables. The shared `interwiki` table allows users to use the same interwiki
 *  prefixes across all wikis. The `user` and `user_properties` tables make all
 *  wikis have the same set of users and user properties/preferences. This does
 *  not affect the user groups, so a user can be a sysop on one wiki and just a
 *  user on another.
 *
 *  To enable a primewiki create the file $m_config/local/primewiki and make
 *  the file contents be the id of the desired wiki.
 *
 *  In order for this to work properly the wikis need to have been created with
 *  a single user table in mind. If you're starting a new wiki farm then you're
 *  all set. If you're importing wikis which didn't previously have shared user
 *  tables, then you'll need to use TBD user-merge script.
 *
 **/
if ( file_exists( "$m_config/local/primewiki" ) ) {

	// grab prime wiki data using closure to encapsulate the data
	// and not overwrite existing config ($wgSitename, etc)
	$primewiki = call_user_func( function() use ( $m_htdocs, $m_config ) {

		$primeWikiId = trim( file_get_contents( "$m_config/local/primewiki" ) );

		require_once "$m_htdocs/wikis/$primeWikiId/config/setup.php";

		if ( isset( $mezaCustomDBname ) ) {
			$primeWikiDBname = $mezaCustomDBname;
		} else {
			$primeWikiDBname = "wiki_$primeWikiId";
		}

		return array(
			'id' => $primeWikiId,
			'database' => $primeWikiDBname,
		);
	} );

	$wgSharedDB = $primewiki[ 'database' ];
	$wgSharedTables = array(
		'user',            // default
		'user_properties', // default
		'interwiki',       // additional
	);

}







/**
 *  6) GENERAL CONFIGURATION
 *
 *
 *
 **/
// memcached settings
$wgMainCacheType = CACHE_MEMCACHED;
$wgParserCacheType = CACHE_NONE; // optional; if set to CACHE_MEMCACHED, templates used to format query results in generic footer don't work
$wgMessageCacheType = CACHE_MEMCACHED; // optional
$wgMemCachedServers = array( "127.0.0.1:11211" );

// memcached is setup and will work for sessions with meza, unless you use
// SimpleSamlPhp. For that reason memcached is disabled for sessions. This will
// be fixed in a later version.
$wgSessionsInObjectCache = false; // optional
$wgSessionCacheType = CACHE_NONE; // optional


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


$wgMaxImageArea = 1.25e10; // Images on [[Snorkel]] fail without this
// $wgMemoryLimit = 500000000; //Default is 50M. This is 500M.


// Increase from default setting for large form
// See https://www.mediawiki.org/wiki/Extension_talk:Semantic_Forms/Archive_April_to_June_2012#Error:_Backtrace_limit_exceeded_during_parsing
// If set to 10million, errors are seen when using Edit with form on mission pages like 41S
// ini_set( 'pcre.backtrack_limit', 10000000 ); //10million
ini_set( 'pcre.backtrack_limit', 1000000000 ); //1 billion


$wgUseImageMagick = true;
$wgImageMagickConvertCommand = '/usr/local/bin/convert';

// Allowed file types
$wgFileExtensions = array(
	'aac',
	'bmp',
	'docx',
	'gif',
	'jpg',
	'jpeg',
	'mpp',
	'mp3',
	'msg',
	'odg',
	'odp',
	'ods',
	'odt',
	'pdf',
	'png',
	'pptx',
	'ps',
	'svg',
	'tiff',
	'txt',
	'xlsx'
);















/**
 *  7) EXTENSION SETTINGS
 *
 *  Code to load the extension "ExtensionLoader", which then installs and loads
 *  other extensions as defined in "ExtensionSettings.php". Note that the file
 *  or files defining which extensions are loaded is configurable below, as is
 *  the path to where extensions are installed.
 */

#
# Enable Semantic MediaWiki semantics
#
enableSemantics( $wikiId );


#
# Semantic MediaWiki Settings (extension loaded via Composer)
#
$smwgQMaxSize = 5000;

#
# SemanticResultFormats formats enabled (beyond defaults)
#

// These are disabled by default because they send data to external
// web services for rendering, which may be considered a data leak
// $srfgFormats[] = 'googlebar';
// $srfgFormats[] = 'googlepie';

// Disabled until the proper dependencies are added (PHPExcel I think)
// $srfgFormats[] = 'excel';

// Enables the "filtered" format. Where do we use this?
$srfgFormats[] = 'filtered';

// Disabled due to some issue on FOD wikis. Confirm, reenable if possible
// $srfgFormats[] = 'exhibit';



// allows adding semantic properties to Templates themselves
// (not just on pages via templates).
// ENABLE THIS AFTER ALL TEMPLATES HAVE BEEN CHECKED FOR PROPER FORM
// i.e. using <noinclude> and <includeonly> properly
// $smwgNamespacesWithSemanticLinks[NS_TEMPLATE] = true;
$smwgNamespacesWithSemanticLinks[NS_TALK] = true;


/**
 *  Code to load the extension "ExtensionLoader", which then installs and loads
 *  other extensions
 */
require_once "$IP/extensions/ExtensionLoader/ExtensionLoader.php";
$egExtensionLoader = new ExtensionLoader();

/**
 * May want to include ParserFunctionHelper in order to extension-ify templates
 */
// 'ParserFunctionHelper' => array(
// 	'git' => 'https://github.com/enterprisemediawiki/ParserFunctionHelper.git',
// 	'branch' => 'master',
// ),

/**
 * ImportUsers is not in wikimedia git, now in github/kghbln. Also, it seems it
 * may not work well with newer versions of MW
 * @url: https://github.com/kghbln/ImportUsers
 * Consider updating and taking into EMW.org
 */
// 'ImportUsers' => array(
// 	'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/ImportUsers.git',
// 	'branch' => 'master',
// 	'globals' => array(
// 		'wgShowExceptionDetails' => true,
// 	)
// ),



#
# Extension:ParserFunctions
#
require_once $egExtensionLoader->registerLegacyExtension(
	"ParserFunctions",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/ParserFunctions.git",
	"REL1_25"
);
$wgPFEnableStringFunctions = true;


#
# Extension:StringFunctionsEscaped
#
require_once $egExtensionLoader->registerLegacyExtension(
	"StringFunctionsEscaped",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/StringFunctionsEscaped.git",
	"REL1_25"
);


#
# Extension:ExternalData
#
require_once $egExtensionLoader->registerLegacyExtension(
	"ExternalData",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/ExternalData.git",
	"REL1_25"
);


#
# Extension:LabeledSectionTransclusion
#
require_once $egExtensionLoader->registerLegacyExtension(
	"LabeledSectionTransclusion",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/LabeledSectionTransclusion.git",
	"REL1_25"
);


#
# Extension:Cite
#
require_once $egExtensionLoader->registerLegacyExtension(
	"Cite",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/Cite.git",
	"REL1_25"
);
$wgCiteEnablePopups = true;


#
# Extension:HeaderFooter
#
// managed by composer due to use of SemanticMeetingMinutes
// 'HeaderFooter' => array(
// 	'git' => 'https://github.com/enterprisemediawiki/HeaderFooter.git',
// 	'branch' => 'master',
// ),


#
# Extension:WhoIsWatching
#
require_once $egExtensionLoader->registerLegacyExtension(
	"WhoIsWatching",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/WhoIsWatching.git",
	"REL1_25"
);
$wgPageShowWatchingUsers = true;


#
# Extension:CharInsert
#
require_once $egExtensionLoader->registerLegacyExtension(
	"CharInsert",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/CharInsert.git",
	"REL1_25"
);


#
# Extension:SemanticForms
#
require_once $egExtensionLoader->registerLegacyExtension(
	"SemanticForms",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/SemanticForms.git",
	"REL1_25"
);


#
# Extension:SemanticInternalObjects
#
require_once $egExtensionLoader->registerLegacyExtension(
	"SemanticInternalObjects",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/SemanticInternalObjects.git",
	"REL1_25"
);


#
# Extension:SemanticCompoundQueries
#
require_once $egExtensionLoader->registerLegacyExtension(
	"SemanticCompoundQueries",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/SemanticCompoundQueries.git",
	"REL1_25"
);


#
# Extension:Arrays
#
require_once $egExtensionLoader->registerLegacyExtension(
	"Arrays",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/Arrays.git",
	"REL1_25"
);


#
# Extension:TitleKey
#
require_once $egExtensionLoader->registerLegacyExtension(
	"TitleKey",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/TitleKey.git",
	"REL1_25"
);


#
# Extension:TalkRight
#
require_once $egExtensionLoader->registerLegacyExtension(
	"TalkRight",
	"https://github.com/enterprisemediawiki/TalkRight.git",
	"master"
);


#
# Extension:AdminLinks
#
require_once $egExtensionLoader->registerLegacyExtension(
	"AdminLinks",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/AdminLinks.git",
	"REL1_25"
);
$wgGroupPermissions['sysop']['adminlinks'] = true;


#
# Extension:DismissableSiteNotice
#
require_once $egExtensionLoader->registerLegacyExtension(
	"DismissableSiteNotice",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/DismissableSiteNotice.git",
	"REL1_25"
);


#
# Extension:BatchUserRights
#
require_once $egExtensionLoader->registerLegacyExtension(
	"BatchUserRights",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/BatchUserRights.git",
	"REL1_25"
);


#
# Extension:HeaderTabs
#
require_once $egExtensionLoader->registerLegacyExtension(
	"HeaderTabs",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/HeaderTabs.git",
	"REL1_25"
);
$htEditTabLink = false;
$htRenderSingleTab = true;


#
# Extension:WikiEditor
#
require_once $egExtensionLoader->registerLegacyExtension(
	"WikiEditor",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/WikiEditor.git",
	"REL1_25"
);
$wgDefaultUserOptions['usebetatoolbar'] = 1;
$wgDefaultUserOptions['usebetatoolbar-cgd'] = 1;

# displays publish button
$wgDefaultUserOptions['wikieditor-publish'] = 1;

# Displays the Preview and Changes tabs
$wgDefaultUserOptions['wikieditor-preview'] = 1;


#
# Extension:CopyWatchers
#
require_once $egExtensionLoader->registerLegacyExtension(
	"CopyWatchers",
	"https://github.com/jamesmontalvo3/MediaWiki-CopyWatchers.git",
	"master"
);


#
# Extension:SyntaxHighlight_GeSHi
#
# consider replacing with SyntaxHighlight_Pygments
# https://gerrit.wikimedia.org/r/mediawiki/extensions/SyntaxHighlight_Pygments.git
#
require_once $egExtensionLoader->registerLegacyExtension(
	"SyntaxHighlight_GeSHi",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/SyntaxHighlight_GeSHi.git",
	"REL1_25"
);


#
# Extension:Wiretap
#
require_once $egExtensionLoader->registerLegacyExtension(
	"Wiretap",
	"https://github.com/enterprisemediawiki/Wiretap.git",
	"master"
);


#
# Extension:ApprovedRevs
#
require_once $egExtensionLoader->registerLegacyExtension(
	"ApprovedRevs",
	"https://github.com/jamesmontalvo3/MediaWiki-ApprovedRevs.git",
	"master"
);
$egApprovedRevsAutomaticApprovals = false;


#
# Extension:InputBox
#
require_once $egExtensionLoader->registerLegacyExtension(
	"InputBox",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/InputBox.git",
	"REL1_25"
);


#
# Extension:ReplaceText
#
require_once $egExtensionLoader->registerLegacyExtension(
	"ReplaceText",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/ReplaceText.git",
	"REL1_25"
);


#
# Extension:Interwiki
#
require_once $egExtensionLoader->registerLegacyExtension(
	"Interwiki",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/Interwiki.git",
	"REL1_25"
);
$wgGroupPermissions['sysop']['interwiki'] = true;


#
# Extension:MasonryMainPage
#
require_once $egExtensionLoader->registerLegacyExtension(
	"MasonryMainPage",
	"https://github.com/enterprisemediawiki/MasonryMainPage.git",
	"master"
);


#
# Extension:WatchAnalytics
#
require_once $egExtensionLoader->registerLegacyExtension(
	"WatchAnalytics",
	"https://github.com/enterprisemediawiki/WatchAnalytics.git",
	"master"
);

// makes Pending Reviews shake after X days
$egPendingReviewsEmphasizeDays = 10;


#
# Extension:NumerAlpha
#
// managed by composer due to use of SemanticMeetingMinutes
// 'NumerAlpha' => array(
// 	'git' => 'https://github.com/jamesmontalvo3/NumerAlpha.git',
// 	'branch' => 'master',
// ),


#
# Extension:Variables
#
require_once $egExtensionLoader->registerLegacyExtension(
	"Variables",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/Variables.git",
	"REL1_25"
);


#
# Extension:YouTube
#
require_once $egExtensionLoader->registerLegacyExtension(
	"YouTube",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/YouTube.git",
	"REL1_25"
);


#
# Extension:ContributionScores
#
require_once $egExtensionLoader->registerLegacyExtension(
	"ContributionScores",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/ContributionScores.git",
	"REL1_25"
);
// Exclude Bots from the reporting - Can be omitted.
$wgContribScoreIgnoreBots = true;

// Exclude Blocked Users from the reporting - Can be omitted.
$wgContribScoreIgnoreBlockedUsers = true;

// Use real user names when available - Can be omitted. Only for MediaWiki 1.19 and later.
$wgContribScoresUseRealName = true;

// Set to true to disable cache for parser function and inclusion of table.
$wgContribScoreDisableCache = false;

//Each array defines a report - 7,50 is "past 7 days" and "LIMIT 50" - Can be omitted.
$wgContribScoreReports = array(
	array(7,50),
	array(30,50),
	array(0,50)
);


#
# Extension:PipeEscape
#
# @todo: The "official" version of this is in an SVN repository. If we need
#        this it should be migrated to Gerrit or an EMW managed git repo.
#        See https://www.mediawiki.org/wiki/Extension:Pipe_Escape
#
#
require_once $egExtensionLoader->registerLegacyExtension(
	"PipeEscape",
	"https://github.com/jamesmontalvo3/MediaWiki-PipeEscape.git",
	"master"
);


#
# Extension:PdfHandler
#
// require_once $egExtensionLoader->registerLegacyExtension(
// 	"PdfHandler",
// 	"https://gerrit.wikimedia.org/r/mediawiki/extensions/PdfHandler",
// 	"REL1_25"
// );
// Location of PdfHandler dependencies
// $wgPdfProcessor = '/usr/bin/gs'; // installed via yum
// $wgPdfPostProcessor = '/usr/local/bin/convert'; // built from source
// $wgPdfInfo = '/usr/local/bin/pdfinfo'; // pre-built binaries installed


#
# Extension:UniversalLanguageSelector
#
require_once $egExtensionLoader->registerLegacyExtension(
	"UniversalLanguageSelector",
	"https://gerrit.wikimedia.org/r/p/mediawiki/extensions/UniversalLanguageSelector.git",
	"REL1_25"
);


#
# Extension:VisualEditor
#
require_once $egExtensionLoader->registerLegacyExtension(
	"VisualEditor",
	"https://gerrit.wikimedia.org/r/p/mediawiki/extensions/VisualEditor.git",
	"REL1_25"
);
// Allow read and edit permission for requests from the server (e.g. Parsoid)
// Ref: https://www.mediawiki.org/wiki/Talk:Parsoid/Archive#Running_Parsoid_on_a_.22private.22_wiki_-_AccessDeniedError
// Ref: https://www.mediawiki.org/wiki/Extension:VisualEditor#Linking_with_Parsoid_in_private_wikis
if ( isset( $_SERVER['REMOTE_ADDR'] ) && isset( $_SERVER['SERVER_ADDR'] )
	&& $_SERVER['REMOTE_ADDR'] == $_SERVER['SERVER_ADDR'] )
{
	$wgServer = preg_replace( '/^http:\/\/([a-zA-Z\d-\.]+):9000/', 'https://$1', $wgServer );
	$wgGroupPermissions['*']['read'] = true;
	$wgGroupPermissions['*']['edit'] = true;
}

// Enable by default for everybody
$wgDefaultUserOptions['visualeditor-enable'] = 1;

// Don't allow users to disable it
$wgHiddenPrefs[] = 'visualeditor-enable';

// OPTIONAL: Enable VisualEditor's experimental code features
#$wgDefaultUserOptions['visualeditor-enable-experimental'] = 1;

// URL to the Parsoid instance
// MUST NOT end in a slash due to Parsoid bug
$wgVisualEditorParsoidURL = 'http://127.0.0.1:8000';

// Interwiki prefix to pass to the Parsoid instance
// Parsoid will be called as $url/$prefix/$pagename
$wgVisualEditorParsoidPrefix = $wikiId;

// Define which namespaces will use VE
$wgVisualEditorNamespaces = array_merge(
	$wgContentNamespaces,
        array( NS_USER,
          NS_HELP,
          NS_PROJECT
	)
);

#
# Extension:Elastica
#
require_once $egExtensionLoader->registerLegacyExtension(
	"Elastica",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/Elastica.git",
	"REL1_25"
);


#
# Extension:CirrusSearch
#
require_once $egExtensionLoader->registerLegacyExtension(
	"CirrusSearch",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/CirrusSearch.git",
	"REL1_25"
);
$wgSearchType = 'CirrusSearch';
//$wgCirrusSearchServers = array( 'search01', 'search02' );


#
# Extension:Echo
#
require_once $egExtensionLoader->registerLegacyExtension(
	"Echo",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/Echo.git",
	"REL1_25"
);
$wgEchoEmailFooterAddress = $wgPasswordSender;


#
# Extension:Thanks
#
require_once $egExtensionLoader->registerLegacyExtension(
	"Thanks",
	"https://gerrit.wikimedia.org/r/mediawiki/extensions/Thanks.git",
	"REL1_25"
);
$wgThanksConfirmationRequired = false;


#
# Extension:Upload Wizard
#
require_once $egExtensionLoader->registerLegacyExtension(
	'UploadWizard',
	'https://gerrit.wikimedia.org/r/mediawiki/extensions/UploadWizard',
	'REL1_25'
);

// Needed to make UploadWizard work in IE, see bug 39877
// See also: https://www.mediawiki.org/wiki/Manual:$wgApiFrameOptions
$wgApiFrameOptions = 'SAMEORIGIN';

// Use UploadWizard by default in navigation bar
$wgUploadNavigationUrl = "$wgScriptPath/index.php/Special:UploadWizard"; //Update with #156
$wgUploadWizardConfig = array(
	'debug' => false,
	'autoCategory' => 'Uploaded with UploadWizard',
	'feedbackPage' => 'Project:UploadWizard/Feedback',
	'altUploadForm' => 'Special:Upload',
	'fallbackToAltUploadForm' => false,
	'enableFormData' => true,  # Should FileAPI uploads be used on supported browsers?
	'enableMultipleFiles' => true,
	'enableMultiFileSelect' => true,
	'tutorial' => array('skip' => true),
	'fileExtensions' => $wgFileExtensions //omitting this can cause errors
);


#
# Extension:CollapsibleVector
#
require_once $egExtensionLoader->registerLegacyExtension(
	'CollapsibleVector',
	'https://gerrit.wikimedia.org/r/mediawiki/extensions/CollapsibleVector',
	'REL1_25'
);




#
# Extension:Flow
#
# Note: Flow removed due to being unable to search discussions. While the
# improved interface is great, it's useless if we can't search our old content.
# See issues #272.
#
// require_once $egExtensionLoader->registerLegacyExtension(
// 	'Flow',
// 	'https://gerrit.wikimedia.org/r/mediawiki/extensions/Flow.git',
// 	'REL1_25'
// );

// // only allow sysops to create new flow boards
// $wgGroupPermissions['sysop']['flow-create-board'] = true;

// // store posts as html using Parsoid
// $wgFlowContentFormat = 'html';

// // use VE
// $wgFlowEditorList = array( 'visualeditor', 'none' );

// // Define which namespaces will use Flow
// $wgNamespaceContentModels[NS_PROJECT_TALK]        = CONTENT_MODEL_FLOW_BOARD;
// $wgNamespaceContentModels[NS_USER_TALK]           = CONTENT_MODEL_FLOW_BOARD;
// $wgNamespaceContentModels[NS_TALK]                = CONTENT_MODEL_FLOW_BOARD;
// $wgNamespaceContentModels[NS_HELP_TALK]           = CONTENT_MODEL_FLOW_BOARD;
// $wgNamespaceContentModels[NS_FILE_TALK]           = CONTENT_MODEL_FLOW_BOARD;
// $wgNamespaceContentModels[NS_CATEGORY_TALK]       = CONTENT_MODEL_FLOW_BOARD;
// $wgNamespaceContentModels[NS_MEDIAWIKI_TALK]      = CONTENT_MODEL_FLOW_BOARD;
// $wgNamespaceContentModels[NS_TEMPLATE_TALK]       = CONTENT_MODEL_FLOW_BOARD;
// $wgNamespaceContentModels[SMW_NS_FORM_TALK]       = CONTENT_MODEL_FLOW_BOARD; // MW throws error: SMW_NS_FORM_TALK not a constant
// $wgNamespaceContentModels[SMW_NS_PROPERTY_TALK]   = CONTENT_MODEL_FLOW_BOARD;
// $wgNamespaceContentModels[SMW_NS_CONCEPT_TALK]    = CONTENT_MODEL_FLOW_BOARD;

// // Connect Flow to Parsoid
// $wgFlowParsoidURL = 'http://127.0.0.1:8000';
// $wgFlowParsoidPrefix = $wikiId;





/**
 *  8) PERMISSIONS
 *
 *
 *
 **/
if ( ! isset( $mezaAuthType ) ) {
	$mezaAuthType = 'anon-edit'; // default: wide open!
}
if ( $mezaAuthType === 'anon-edit' ) {

    // allow anonymous read
    $wgGroupPermissions['*']['read'] = true;
    $wgGroupPermissions['user']['read'] = true;

    // allow anonymous write
    $wgGroupPermissions['*']['edit'] = true;
    $wgGroupPermissions['user']['edit'] = true;

}

else if ( $mezaAuthType === 'anon-read' ) {

    // allow anonymous read
    $wgGroupPermissions['*']['read'] = true;
    $wgGroupPermissions['user']['read'] = true;

    // allow anonymous write
    $wgGroupPermissions['*']['edit'] = false;
    $wgGroupPermissions['user']['edit'] = true;

}

else if ( $mezaAuthType === 'user-edit' ) {

    // no anonymous
    $wgGroupPermissions['*']['read'] = false;
    $wgGroupPermissions['*']['edit'] = false;

    // users read and write
    $wgGroupPermissions['user']['read'] = true;
    $wgGroupPermissions['user']['edit'] = true;

}

else if ( $mezaAuthType === 'user-read' ) {

    // no anonymous
    $wgGroupPermissions['*']['read'] = false;
    $wgGroupPermissions['*']['edit'] = false;

    // users read NOT write
    $wgGroupPermissions['user']['read'] = true;
    $wgGroupPermissions['user']['edit'] = false;

    $wgGroupPermissions['Contributor'] = $wgGroupPermissions['user'];
    $wgGroupPermissions['Contributor']['edit'] = true;

}

else if ( $mezaAuthType === 'viewer-read' ) {

    // no anonymous or ordinary users
    $wgGroupPermissions['*']['read'] = false;
    $wgGroupPermissions['*']['edit'] = false;
    $wgGroupPermissions['user']['read'] = false;
    $wgGroupPermissions['user']['edit'] = false;

    // load the access-denied extension because there appears to be no way to
    // prevent registered users from viewing pages in stock mediawiki
    require_once $egExtensionLoader->registerLegacyExtension(
        'AccessDenied',
        'https://github.com/JamesMontalvo3/AccessDenied.git',
        'master'
    );
    $egAccessDeniedViewerGroup = "Viewer";

    // create the Viewer group. Note this group requires no permissions
    // since the extension will manage whether they can get into the wiki
    $wgGroupPermissions['Viewer'] = $wgGroupPermissions['user'];

    // Create a contributors group that can edit
    $wgGroupPermissions['Contributor'] = $wgGroupPermissions['user'];
    $wgGroupPermissions['Contributor']['edit'] = true;

}



/**
 *  9) LOAD OVERRIDES
 *
 *
 *
 *
 **/
if ( file_exists( "$m_config/local/overrides.php" ) ) {
	require_once "$m_config/local/overrides.php";
}
if ( file_exists( "$m_htdocs/wikis/$wikiId/config/overrides.php" ) ) {
	require_once "$m_htdocs/wikis/$wikiId/config/overrides.php";
}
