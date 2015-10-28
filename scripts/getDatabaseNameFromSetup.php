<?php
/**
 *  The purpose of this script is simply to return the $mezaCustomDBname from
 *  a wiki's setup.php file if there is one. This allows shell scripts to
 *  easily retrieve this value using this very quick PHP script.
 **/


$setupScript = $argv[1];

include $setupScript;

if ( isset( $mezaCustomDBname ) ) {
	echo $mezaCustomDBname;
}

// else no output
