<?php

$blenderTitle = "Meza Wikis";
$blenderServer = "https://" . trim( file_get_contents( '/opt/meza/config/local/domain' ) ) . "/";
$blenderScriptPath = '/WikiBlender';

$primeWikiFile = '/opt/meza/config/local/primewiki';
if ( file_exists( $primeWikiFile ) ) {
	$primeWiki = file_get_contents( $primeWikiFile );
	$blenderFavicon = "/wikis/$primeWiki/config/favicon.ico";
}
$blenderWikisDir = __DIR__ . '/../wikis';

// don't think we specify any header wikis by default (wikis at the top above others)
$blenderHeaderWikiTitle = false;
$blenderHeaderWikis = array();

// since there's no header wikis, no reason for a special header here
$blenderMiddleWikiTitle = false;

// no footer wikis either
$blenderFooterWikiTitle = false;
$blenderFooterWikis = array();

// links at the bottom
$blenderFooterLinks = array(
	"<a href='https://github.com/enterprisemediawiki/meza'>meza on github</a>",
	"<a href='https://enterprisemediawiki.org'>enterprisemediawiki.org</a>",
);
// $blenderAdmins = array(
// 	"admin@example.com" => "Admin email address",
// );
