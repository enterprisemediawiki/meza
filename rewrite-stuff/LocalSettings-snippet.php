<?php




if( $wgCommandLineMode ) {

	// get $wikiId from environtment variable
	$wikiId = getenv( $mezaWikiEnvVarName );

}
else {

	// get $wikiId from URI
	$uriParts = explode( '/', $_SERVER['REQUEST_URI'] );
	$wikiId = strtolower( $uriParts[1] ); // URI has leading slash, so $uriParts[0] is empty string

}

// for now just a dummy list of wikis
$wikis = array( 'eva', 'oso', 'robo' );


if ( in_array( $wikiId, $wikis ) ) {

	// https://www.mediawiki.org/wiki/Manual:$wgScriptPath
	$wgScriptPath = "/$wikiId";

	// https://www.mediawiki.org/wiki/Manual:$wgUploadPath
	$wgUploadPath = "/wikis/$wikiId/images";

	// https://www.mediawiki.org/wiki/Manual:$wgUploadDirectory
	$wgUploadDirectory = "/var/www/meza1/htdocs/wikis/$wikiId/images";

	// https://www.mediawiki.org/wiki/Manual:$wgLogo
	$wgLogo = "/wikis/$wikiId/config/logo.png";

	// https://www.mediawiki.org/wiki/Manual:$wgEmergencyContact
	// $wgEmergencyContact = ???

	// https://www.mediawiki.org/wiki/Manual:$wgPasswordSender
	// $wgPasswordSender = ???

}
else {

	// handle invalid wiki
	die( "No sir, I ain't heard'a no wiki that goes by the name \"$wikiId\"" );

}