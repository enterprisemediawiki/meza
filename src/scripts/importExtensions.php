<?php
error_reporting(E_ALL);
# normalize names by removing any spaces
$core  = `grep -Po 'name\: (.*)' /opt/meza/config/core/MezaCoreExtensions.yml | sort | awk --field-separator=: '{print $2}' | sed s'/[ \t]*//g'`;
$local = `grep -Po 'name\: (.*)' /opt/conf-meza/public/MezaLocalExtensions.yml | sort | awk --field-separator=: '{print $2}' | sed s'/[ \t]*//g'`;

print "Here are the extensions in core\n$core";

print "\n\n Here are additional extensions from MezaLocalExtensions.yml\n$local";

$core = explode("\n", $core);
$local = explode("\n", $local);

// var_dump($core);

$api = $argv[1];

if ( ($api == null) || ($api == false) || ($api == '') ) {
  die (' You must supply the domain and path to your wiki api as the first argument. e.g. https://freephile.org/w/api.php' );
}
$endpoint = $api . '?action=query&meta=siteinfo&siprop=extensions&format=json';
// $extension_json = file_get_contents( 'https://freephile.org/w/api.php?action=query&meta=siteinfo&siprop=extensions&format=json' );
$extension_json = file_get_contents( $endpoint );

$extension_json = utf8_encode( $extension_json ); // for bad old implementations where a BOM may exist

$extension_php = json_decode ( $extension_json );


// print_r ($extension_php->{'query'}->{'extensions'});
$extension_php = $extension_php->{'query'}->{'extensions'};

function cmp( $a , $b ) {
  return strcmp( $a->name, $b->name );
}
// usort will sort the array in place
usort( $extension_php, 'cmp' );

// print_r ($extension_php);
// print "found " . count($extension_php) . " extensions\n";

$names = array();
foreach ( $extension_php as $ext ) {
    $names[] = str_replace( " ", "", $ext->{name} );
}


echo "Comparing " . count( $names ) . " extensions found at $api with the " . count( $core ) . " extensions in core and the " . count( $local ) . " found locally.\n";
$unhandled = array_diff( $names, $core, $local );
echo "Left with " . count( $unhandled ) . " not in core or local\n";



foreach ( $extension_php as $ext ) {
  if ( in_array( $ext->name, $unhandled ) ) {
    echo "-";
    echo " name: $ext->name\n";
    echo "  repo: " . $ext->{"vcs-url"} . "\n";
    echo $ext->{"vcs-version"} ? '  version: ' . $ext->{"vcs-version"} ."\n" : "  version: $ext->version\n";
  }
}

// $existing = yaml_parse_file( '/opt/meza/config/core/MezaCoreExtensions.yml' );

// var_dump ($existing);

