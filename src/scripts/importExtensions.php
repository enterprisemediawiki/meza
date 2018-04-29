<?php
error_reporting(E_ALL);

$HELP = <<<HERE
Supply the full URL to your wiki API as the first argument. e.g.
https://freephile.org/w/api.php to get a list of extensions which still need
to be added locally.

If the Wiki API is access restricted, then execute a
'?action=query&meta=siteinfo&siprop=extensions&format=json' API query in that
environment and save the results to a file with a .json extension.

Then supply the path to that file as the argument to this function.
HERE;

# normalize names by removing any spaces
$core  = `grep -Po 'name\: (.*)' /opt/meza/config/core/MezaCoreExtensions.yml | sort | awk --field-separator=: '{print $2}' | sed s'/[ \t]*//g'`;
$local = `grep -Po 'name\: (.*)' /opt/conf-meza/public/MezaLocalExtensions.yml | sort | awk --field-separator=: '{print $2}' | sed s'/[ \t]*//g'`;

print "Here are the extensions in core\n$core";

print "\n\n Here are additional extensions from MezaLocalExtensions.yml\n$local";

// $core is Meza, and $local are any local additions found in MezaLocalExtensions
$core = explode("\n", trim($core));
$local = explode("\n", trim($local));

$api = $argv[1];

if ( ($api == null) || ($api == false) || ($api == '') ) {
  fwrite(STDERR, $HELP);
  exit(1);
}

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
// print_r ($extension_php->{'query'}->{'extensions'});
$extension_php = $extension_php->{'query'}->{'extensions'};

function cmp( $a , $b ) {
  return strcmp( $a->name, $b->name );
}

function nameFirst( $a, $b ) {
  if ($a == 'name') {
    $return = -1; // if we make it 'less' it will be first in the array
  } else if ($b == 'name') {
    $return = 1;
  } else {
    $return = 0;
  }
  return $return;
}
// usort will sort the array in place
// $extension_php is an array, each member is an object
usort( $extension_php, 'cmp' );

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

echo count( $incore ) . " handled by Meza Core\n";
echo count( $inlocal ) . " handled locally\n";
echo "Left with " . count( $unhandled ) . " not in Core Meza or Locally\n";


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
foreach ( $extensions as $ext ) {
  if ( in_array( $ext['name'], $unhandled ) ) {
    echo "\n- CUSTOM\n";
  } elseif ( in_array( $ext['name'], $incore ) ) {
    echo "\n- Core\n";
} elseif ( in_array( $ext['name'], $inlocal ) ) {
    echo "\n- Local\n";
  }
  foreach ( $ext as $k => $v ) {
    // sometimes the values have spurious newlines
    $v = trim($v);
    echo "  $k : $v\n";
  }
}
