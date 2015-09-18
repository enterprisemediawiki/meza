<?php

global $wikiId;

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


