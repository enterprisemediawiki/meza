<?php
/**
 * Script to generate YAML file for landing page generation
 *
 *
 **/

require_once "/opt/.deploy-meza/config.php";

// get list of directories, removing . and ..
$wikiDirs = array_slice( scandir( "$m_htdocs/wikis" ), 2 );

// keep only directories, not files, in $blenderWikisDir
$wikiDirs = array_filter( $wikiDirs, function( $wiki ) use ( $m_htdocs ) {
	return is_dir( "$m_htdocs/wikis/$wiki" );
} );

$wikisData = [];

foreach ($wikiDirs as $wiki) {
	include "$m_htdocs/wikis/$wiki/config/preLocalSettings.d/base.php";

	if ( $m_wiki_url_style === 'subdomain' ) {
		$path = "https://$wiki.$wiki_app_fqdn";
		$api  = "$path/w/api.php";
	}
	else {
		$path = "https://$wiki_app_fqdn/$wiki";
		$api  = "$path/api.php"
	}

	$wikisData[] = [
		'id'        => $wiki,
		'name'      => $wgSitename,
		'path'      => $path,
		'api_path'  => $api,
		'logo_path' => "wikis/$wiki/config/logo.png",
	];
}

// $yaml = yaml_emit( [ 'wikis_metadata' => $wikisData ] );
$yaml = yaml_emit( $wikisData );

// echo $yaml;

file_put_contents( "$m_deploy/wikis_metadata.yml", $yaml );
