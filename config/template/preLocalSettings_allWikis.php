<?php

/**
 * preLocalSettings.php is used to modify all wiki settings. This is where any
 * any changes to the standard meza configuration should be kept. It also
 * is where database user and password info is stored
 **/


/**
 * Enables or disables wiki email capabilities for all wikis, regardless of
 * of what their individual settings say.
 *
 **/
// disabled by default for now, should be enabled later for
$mezaEnableAllWikiEmail = false;

// https://www.mediawiki.org/wiki/Manual:$wgPasswordSender
$wgPasswordSender = "admin@example.com";

// https://www.mediawiki.org/wiki/Manual:$wgEmergencyContact
$wgEmergencyContact = $wgPasswordSender;

// set a default $mezaAuthType for all wikis that don't specify one
// $mezaAuthType = 'viewer-read';

// Creating custom namespace
/*
	define("NS_TCHB", 3000);
	define("NS_TCHB_TALK", 3001);
	$wgExtraNamespaces[NS_TCHB] = "TCHB";
	$wgExtraNamespaces[NS_TCHB_TALK] = "TCHB_talk";
	$wgContentNamespaces[] = NS_TCHB;
*/
	
