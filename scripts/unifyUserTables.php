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

