<?php
error_reporting(E_ALL);

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

$HELP = <<<HERE
This script helps you identify different extensions used in a 3rd-party wiki compared to Meza.

It also compares those 3rd-party "custom" extensions to whatever you've setup in
/opt/conf-meza/public/MezaLocalExtensions.yml as your improved distribution of Meza.
 Note that if MezaLocalExtensions.yml is not found, this script will use the QualityBox
 setup found at https://github.com/freephile/meza-conf-public/blob/master/MezaLocalExtensions.yml
 (You would need to customize this script to use your own public config repo.)

Supply the full URL to the external wiki API as the script argument. e.g.
`php importExtensions.php https://freephile.org/w/api.php`
to get a list of extensions which would need to be added locally.

If the 3rd-party wiki API is access restricted, then execute a
'?action=query&meta=siteinfo&siprop=extensions&format=json' API query in that
environment and save the text output to a file with a .json extension.

Then supply the path to that file as the argument to this function.
HERE;

$mezaCoreExtensionsFile = '/opt/meza/config/core/MezaCoreExtensions.yml';
$mezaCoreExtensionsURL = 'https://raw.githubusercontent.com/freephile/meza/master/config/core/MezaCoreExtensions.yml';
$localExtensionsFile = '/opt/conf-meza/public/MezaLocalExtensions.yml';
$localExtensionsURL = 'https://raw.githubusercontent.com/freephile/meza-conf-public/master/MezaLocalExtensions.yml';
$coreYml = ( file_exists( $mezaCoreExtensionsFile ) ) ? file_get_contents($mezaCoreExtensionsFile) : file_get_contents($mezaCoreExtensionsURL) ;
$localYml = ( file_exists( $localExtensionsFile ) ) ? file_get_contents($localExtensionsFile) : file_get_contents($localExtensionsURL) ;

# normalize names by removing any spaces
# grep -Po 'name\: (.*)'  /opt/meza/config/core/MezaCoreExtensions.yml | sort | awk --field-separator=: '{print $2}' | sed s'/[ \t]*//g';

$pattern = '#name\: (.*)#';
preg_match_all ($pattern, $coreYml, $matches);
$core = $matches[1];
preg_match_all ($pattern, $localYml, $matches);
$local = $matches[1];
sort($core);
$core = str_replace(' ', '', $core);
sort($local);
$local = str_replace(' ', '', $local);

$api = $argv[1];
// show help if no argument is supplied
if ( ($api == null) || ($api == false) || ($api == '') ) {
  fwrite(STDERR, $HELP);
  exit(1);
}

// sniff the argument and if it ends in 'api', use the api querystring. if it ends in json, just read
if ( substr($api, -3) == 'api' ) {
  $endpoint = $api . '?action=query&meta=siteinfo&siprop=extensions&format=json';
} else if ( substr($api, -4) == 'json' ) {
  $endpoint = $api;
} else {
  fwrite(STDERR, $HELP);
  exit(2);
}

$extension_json = file_get_contents( $endpoint );
// for bad old implementations where a BOM may exist
$extension_json = utf8_encode( $extension_json );
$extension_php = json_decode ( $extension_json );
// use just the part we want
$extension_php = $extension_php->{'query'}->{'extensions'};

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

echo "Comparing " . count( $names ) . " extensions found at $api with the " .
  count( $core ) . " extensions in core and the " . count( $local ) .
  " found locally.\n";
$unhandled = array_diff( $names, $core, $local );
$incore = array_intersect( $names, $core );
$inlocal = array_intersect( $names, $local );

echo count( $incore ) . " handled by Core\n";
echo count($inlocal ) . " handled by MezaLocalExtensions\n";
echo "Left with " . count( $unhandled ) . " custom (not in Meza Core nor MezaLocalExtensions)\n";


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

    @param array $extension - The extension information that you want to print out.
*/
function printExtensionInfo ($extension) {
    echo sprintf ("##  %s\n", $extension['name']);
    foreach ( $extension as $k => $v ) {
      if ($k != 'name') {
            $v = trim($v);
            echo "  $k : $v\n";
        }
    }
}

// $extension_php is an array of objects. each with several properties
// We'll add a property 'handler' to group extensions by where they're handled.
for ($i=0; $i < count($extensions); $i++ ) {
  if ( in_array( $extensions[$i]['name'], $unhandled ) ) {
    $extensions[$i]['handler'] = 'Proprietary';
  } elseif ( in_array( $extensions[$i]['name'], $incore ) ) {
    $extensions[$i]['handler'] = 'Meza Core';
} elseif ( in_array( $extensions[$i]['name'], $inlocal ) ) {
    $extensions[$i]['handler'] = 'QualityBox';
} else {
    $extensions[$i]['handler'] = 'Unknown';
}

}

#################  OUTPUT #################################
// Now we'll output the extensions grouped by where they're handled:

echo  "=== Meza Core Extensions ===\n";
foreach ( $extensions as $ext ) {
  if ($ext['handler'] === 'Meza Core') {
      printExtensionInfo($ext);
    }
}


echo  "=== QualityBox Added Extensions ===\n";
foreach ( $extensions as $ext ) {
  if ($ext['handler'] === 'QualityBox') {
      printExtensionInfo($ext);
  }
}

echo  "=== Custom Extensions ===\n";
foreach ( $extensions as $ext ) {
  if ($ext['handler'] == 'Proprietary') {
      printExtensionInfo($ext);
  }
}

echo  "=== Unknown Extensions ===\n";
foreach ( $extensions as $ext ) {
  if ($ext['handler'] == 'Unknown') {
      printExtensionInfo($ext);
  }
}

// $allkeys = array_unique($allkeys, SORT_LOCALE_STRING);
// print_r($allkeys);

// $existing = yaml_parse_file( '/opt/meza/config/core/MezaCoreExtensions.yml' );

// var_dump ($existing);
