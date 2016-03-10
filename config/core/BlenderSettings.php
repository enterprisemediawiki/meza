<?php

// Server path
$blenderServer = "https://" . trim( file_get_contents( '/opt/meza/config/local/domain' ) ) . "/";

// Script path
$blenderScriptPath = '/WikiBlender';

// If there is a prime wiki, use its favicon as the landing page favicon
$primeWikiFile = '/opt/meza/config/local/primewiki';
if ( file_exists( $primeWikiFile ) ) {
	$primeWiki = file_get_contents( $primeWikiFile );
	$blenderFavicon = "/wikis/$primeWiki/config/favicon.ico";
}

// Location of wikis directory
$blenderWikisDir = __DIR__ . '/../wikis';

// Everything above is standard for all meza. This file has server-specific settings.
require_once '/opt/meza/config/local/LandingPage.php';
