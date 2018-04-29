<?php
error_reporting(E_ALL);
# normalize names by removing any spaces
$core  = `grep -Po 'name\: (.*)' /opt/meza/config/core/MezaCoreExtensions.yml | sort | awk --field-separator=: '{print $2}' | sed s'/[ \t]*//g'`;
$local = `grep -Po 'name\: (.*)' /opt/conf-meza/public/MezaLocalExtensions.yml | sort | awk --field-separator=: '{print $2}' | sed s'/[ \t]*//g'`;

print "Here are the extensions in core\n$core";

print "\n\n Here are additional extensions from MezaLocalExtensions.yml\n$local";

$core = explode("\n", trim($core));
$local = explode("\n", trim($local));

// var_dump($core);

$api = $argv[1];

if ( ($api == null) || ($api == false) || ($api == '') ) {
  exit (' Supply the full URL to your wiki API as the first argument. e.g. https://freephile.org/w/api.php to get a list of extensions which still need to be added locally' );
}
$endpoint = $api . '?action=query&meta=siteinfo&siprop=extensions&format=json';
//$extension_json = file_get_contents( 'https://freephile.org/w/api.php?action=query&meta=siteinfo&siprop=extensions&format=json' );
$extension_json = file_get_contents( $endpoint );
// $extension_json = file_get_contents( $api );

$extension_json = utf8_encode( $extension_json ); // for bad old implementations where a BOM may exist

$extension_php = json_decode ( $extension_json );


// print_r ($extension_php->{'query'}->{'extensions'});
$extension_php = $extension_php->{'query'}->{'extensions'};

function cmp( $a , $b ) {
  return strcmp( $a->name, $b->name );
}

function nameFirst( $a, $b ) {
//  echo "comparing $a with $b ";
  if ($a == 'name') {
    $return = -1; // if we make it 'less' it will be first in the array
  } else if ($b == 'name') { 
    $return = 1;
  } else {
    $return = 0;
  }
//  echo "Returning $return\n";
  return $return;
}
// usort will sort the array in place
// $extension_php is an array, each member is an object
usort( $extension_php, 'cmp' );
// print_r ($extension_php); die();
// print "found " . count($extension_php) . " extensions\n";

$names = array();
$extensions = array();
foreach ( $extension_php as $ext ) {
    $names[] = str_replace( " ", "", $ext->{"name"} );
    $extensions[] = (array) $ext; // cast each object to an array
}


echo "Comparing " . count( $names ) . " extensions found at $api with the " . count( $core ) . " extensions in core and the " . count( $local ) . " found locally.\n";
$unhandled = array_diff( $names, $core, $local );
$incore = array_intersect( $names, $core );
$inqb = array_intersect( $names, $local );

echo count( $incore ) . " handled by Core\n";
echo count( $inqb ) . " handled by QualityBox\n";
echo "Left with " . count( $unhandled ) . " not in Core Meza or QualityBox\n";


/**
Although all extensions won't define each of these keys,
These are the possible keys that you'll see
    [0] => type
    [1] => name
    [2] => descriptionmsg
    [3] => author
    [4] => url
    [5] => version
    [12] => vcs-system
    [13] => vcs-version
    [14] => vcs-url
    [15] => vcs-date
    [16] => license-name
    [17] => license
    [18] => credits
    [21] => namemsg
    [29] => description
*/
//$allkeys = array();
// var_dump($extension_php); exit();
// $extension_php is an array of objects. each with several properties
foreach ( $extensions as $ext ) {
 // echo "sorting ${ext['name']}\n";
 // uksort( $ext, 'nameFirst' );    
  if ( in_array( $ext['name'], $unhandled ) ) {
    echo "\n- CUSTOM\n";
  } elseif ( in_array( $ext['name'], $incore ) ) {
    echo "\n- Core\n";
  } elseif ( in_array( $ext['name'], $inqb ) ) {
    echo "\n- QualityBox\n";
  }
  foreach ( $ext as $k => $v ) {
//    $allkeys[] = $k;
    $v = trim($v);
    echo "  $k : $v\n";
  }
}
// $allkeys = array_unique($allkeys, SORT_LOCALE_STRING);
// print_r($allkeys);

// $existing = yaml_parse_file( '/opt/meza/config/core/MezaCoreExtensions.yml' );

// var_dump ($existing);
