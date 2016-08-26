<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Meza Backup Listing</title>
</head>
<body>
<h1>Backup Files</h1>

<?php

# Debug
// ini_set('display_errors', 1);
// ini_set('display_startup_errors', 1);
// error_reporting(E_ALL);

$domain = trim( file_get_contents( '/opt/meza/config/local/domain' ) );

// if there's a SAML config file, we need to authenticate with SAML, like, now.
if ( is_file("/opt/meza/config/local/SAMLConfig.php") ) {
  require_once __DIR__ . '/NonMediaWikiSimpleSamlAuth.php';
}

$as = new SimpleSAML_Auth_Simple('default-sp');
$as->requireAuth();
$attributes = $as->getAttributes();
$AUID = $attributes['AUID'][0];

$arrContextOptions=array(
    "ssl"=>array(
        "verify_peer"=>false,
        "verify_peer_name"=>false,
    ),
); 

$path = realpath('/opt/meza/backup');
$undesiredStrings = array(
  ".", 
  "..",
  ".DS_Store",
  ".htaccess",
  "README",
);

$wikis = scandir( $path );

// Remove things like "." and ".." and such as maps
$wikis = array_diff($wikis, $undesiredStrings);

foreach( $wikis as $wiki ){

  // Array of users allowed to see backup directory listing
  // Empty by default; Names are added for each wiki if a config file exists
  $allowedUsers = array(
  );

  // if there's a config file with a list of users allowed to download backup files, use it
  if ( is_file("/opt/meza/backup/$wiki/config/backupDownloaders.php") ) {
    require_once "/opt/meza/backup/$wiki/config/backupDownloaders.php";
  }

  if ( in_array($AUID, $allowedUsers) ) {

    // Display name of wiki
    echo "<h2>$wiki</h2>";
    echo "<ul>";

    // Get contents of wiki directory
    $objects = scandir( $path . "/" . $wiki );

    $dbDumps = preg_grep("/^(.*)_wiki.sql/", $objects);

    // Display contents of directory with links
    foreach( $dbDumps as $dbDump ){
      echo "<li><a href='https://$domain/download-backup.php?wiki=$wiki&file=$dbDump'>" . $dbDump . "</a></li>";
    }

    // Display config files
    echo "<li><b>Config/</b></li>";
    echo "<ul>";

    // Get contents of wiki's config directory
    $objects = scandir( $path . "/" . $wiki . "/config" );

    // Remove things like "." and ".." and such as maps
    $objects = array_diff($objects, $undesiredStrings);

    foreach( $objects as $object ){
      // Display links to config files
      echo "<li><a href='https://$domain/download-backup.php?wiki=$wiki&dir=config&file=$object'>$object</a></li>";
    }

    echo "</ul>";

    // Display link to "light" file tarball
    // echo "<li><a href=http://jsc-sma-dkmswiki.ndc.nasa.gov/backup/$wiki/$object>Files</a></li>";

    echo "</ul>";

  }

}

?>

</body>
</html>


