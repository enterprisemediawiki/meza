<?php
/*

  _______ _     _                _                       _ _
 |__   __| |   (_)              | |                     ( ) |
    | |  | |__  _ ___         __| | ___   ___  ___ _ __ |/| |_
    | |  | '_ \| / __|       / _` |/ _ \ / _ \/ __| '_ \  | __|
    | |  | | | | \__ \      | (_| | (_) |  __/\__ \ | | | | |_
    |_|  |_| |_|_|___/       \__,_|\___/ \___||___/_| |_|  \__|
                    | |                 | |
 __      _____  _ __| | __    _   _  ___| |_
 \ \ /\ / / _ \| '__| |/ /   | | | |/ _ \ __|
  \ V  V / (_) | |  |   <    | |_| |  __/ |_ _
   \_/\_/ \___/|_|  |_|\_\    \__, |\___|\__(_)
                               __/ |
                              |___/
*/


/*

PREP WORK:

* DELETE external_user table. See https://www.mediawiki.org/wiki/Manual:External_user_table
* ADD extensions tables to this


OPEN QUESTIONS:

* How to merge user.user_editcount across multiple DBs? (sum all?)
* How to handle user.user_registration across multiple DBs? (take lowest?)
*


*/


$wikiDBs = array(
	'wiki_eva',
	'wiki_robo',
	'wiki_mod',
	'wiki_dd_ms',
);

$initialOffset = 10000; // make sure this is larger than your largest user ID

###############################################
#
# No changes required below here
#
###############################################



$idAndNameTables = array(
	"archive"       => array( "idField" => "ar_user",  "userNameField" => "ar_user_text" ),
	"filearchive"   => array( "idField" => "fa_user",  "userNameField" => "fa_user_text" ),
	"image"         => array( "idField" => "img_user", "userNameField" => "img_user_text" ),
	"logging"       => array( "idField" => "log_user", "userNameField" => "log_user_text" ),
	"oldimage"      => array( "idField" => "oi_user",  "userNameField" => "oi_user_text" ),
	"recentchanges" => array( "idField" => "rc_user",  "userNameField" => "rc_user_text" ),
	"revision"      => array( "idField" => "rev_user", "userNameField" => "rev_user_text" ),
);

// @FIXME: how to handle this table?
"ipblocks"      => array( "idField" => "ipb_user", TBD_SOMETHING => "ipb_by", TBD_SOMETHING_ELSE => ipb_by_text ),

$userTable = array( "idField" => "user_id", "userNameField" => "user_name" );


$idOnlyTables = array(
	"page_restrictions"  => array( "idField" => "pr_user" ),
	"protected_titles"   => array( "idField" => "pt_user" ),
	"uploadstash"        => array( "idField" => "us_user" ),
	"user_former_groups" => array( "idField" => "ufg_user" ),
	"user_groups"        => array( "idField" => "ug_user" ),
	"user_newtalk"       => array( "idField" => "user_id" ),
	"user_properties"    => array( "idField" => "up_user" ),
	"watchlist"          => array( "idField" => "wl_user" ),
);






// For each database, add $initialOffset to all user IDs in all tables
// this just makes it so user ids are always unique
foreach( $wikiDBs as $wiki => $db ) {

	foreach ( $idAndNameTables + $idOnlyTables + array( "user" => $userTable ) as $tableName => $tableInfo ) {
		$idField = $tableInfo['idField'];
		fakequeryfunction( "UPDATE $tableName SET $idField = $idField + $initialOffset" );
	}

	// @FIXME: Is this good?
	fakequeryfunction( "UPDATE ipblocks SET ipb_user = ipb_user + $initialOffset, ipb_by = ipb_by + $initialOffset")

}





$userArray = array();

// Read user table for all wikis, add to $userArray giving each username a new unique ID
foreach( $wikiDBs as $wiki ) {

	// connect to database

	// SELECT entire user table
	$result = fakequeryfunction( "SELECT * ..." );

	foreach( $result as $user ) {

		if ( ! isset( $userArray[$user] ) ) {
			$newId = count( $userArray ) + 1;
			// give new ID
			$userArray[$user] = array(
				"newId" => $newId,

			);
		}
	}

}


foreach ( $wikiDBs as $wiki ) {

	// Loop through the ~17 tables with usernames and user IDs (except the user table) and:

		// For tables with username and id columns: replace the id with the id from $userArray
		foreach( $userArray as $userName => $newUserId ) {
			foreach( $tablesWithUsernameAndId as $tableName => $tableInfo ) {
				$idField = $tableInfo['idField'];
				$userNameField = $tableInfo['userNameField'];
				fakequeryfunction( "UPDATE $tableName SET $idField=$newUserId WHERE $userNameField=$userName" );
			}
		}

		// For tables with just username (I don't think there are any): No change

		// For tables with just id: Lookup the ID in the user table, use username to get new ID from $UserArray
		$thisWikiUserTable = fakequeryfunction( "SELECT user_id, user_name FROM user" );
		$thisWikiUserIds = array();
		foreach( $thisWikiUserTable as $row ) {
			$thisWikiUserIds[ $row['user_name'] ] = $row['user_id'];
		}
		foreach( $userArray as $userName => $newUserId ) {
			$oldUserId = $thisWikisUserIds[ $userName ];
			foreach( $tablesWithJustId as $tableName => $tableInfo ) {
				$idField = $tableInfo['idField'];
				fakequeryfunction( "UPDATE $tableName SET $idField=$newUserId WHERE $idField=$oldUserId" );
			}
		}

	// Update user table IDs (or skip this step in most wikis since we'll only be using one wiki's user table)

}


// Create new user table on the one wiki with the shared user table

