<?php
/**
 * This script adds a user to mediawiki. It is meant to initialize meza.
 *
 * Usage:
 *  no parameters
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 * http://www.gnu.org/copyleft/gpl.html
 *
 * @author James Montalvo
 * @ingroup Maintenance
 */
require_once( '/opt/meza/htdocs/mediawiki/maintenance/Maintenance.php' );
class MezaUnifyUserTables extends Maintenance {

	public $recordDir;
	public $tablesToModify = array(

		// tables with id only
		"page_restrictions"  => array(
			"unique" => "pr_id",
			"idField" => "pr_user"
		),
		"protected_titles"   => array(
			"unique" => array("pt_namespace","pt_title"),
			"idField" => "pt_user"
		),
		"uploadstash"        => array(
			"unique" => "us_id",
			"idField" => "us_user"
		),
		"user_former_groups" => array(
			"unique" => array("unique_username" => "user.user_name","ufg_group"), // unique replace ufg_user
			"idField" => "ufg_user"
		),
		"user_groups"        => array(
			"unique" => array("unique_username" => "user.user_name", "ug_group"), // unique replace ug_user
			"idField" => "ug_user"
		),
		"user_newtalk"       => array(
			"unique" => array("unique_username" => "user.user_name","user_ip"), // unique replace user_id
			"idField" => "user_id"
		),
		"watchlist"          => array(
			"unique" => array("unique_username" => "user.user_name","wl_namespace","wl_title"), // unique replace wl_user
			"idField" => "wl_user"
		),


		// these have IDs and usernames, but usernames should not need to be modified or used
		"archive"       => array(
			"unique" => "ar_id",
			"idField" => "ar_user",
			"userNameField" => "ar_user_text"
		),
		"filearchive"   => array(
			"unique" => "fa_id",
			"idField" => "fa_user",
			"userNameField" => "fa_user_text"
		),
		"image"         => array(
			"unique" => "img_name",
			"idField" => "img_user",
			"userNameField" => "img_user_text"
		),
		"logging"       => array(
			"unique" => "log_id",
			"idField" => "log_user",
			"userNameField" => "log_user_text"
		),
		"oldimage"      => array(
			// tried oi_sha1 (not unique) and oi_archive_name (sometimes blank)
			"unique" => array('oi_name','oi_timestamp'),
			"idField" => "oi_user",
			"userNameField" => "oi_user_text"
		),
		"recentchanges" => array(
			"unique" => "rc_id",
			"idField" => "rc_user",
			"userNameField" => "rc_user_text"
		),
		"revision"      => array(
			"unique" => "rev_id",
			"idField" => "rev_user",
			"userNameField" => "rev_user_text"
		),


		// extension tables
		'watch_tracking_user' => array(
			"unique" => array("tracking_timestamp", "unique_username" => "user.user_name"), // unique replace user_id
			"idField" => 'user_id'
		),

	);


	public $successes = 0;
	public $failures = 0;
	public $totalChecks = 0;

	public $userTable = array( "idField" => "user_id", "userNameField" => "user_name" );
	public $userPropsTable = array(
		"unique" => array("up_user", "up_property"),
		"idField" => "up_user"
	);

	public $userTableRows = false;

	// If you have a wiki with more than a million users, pay me to update this
	public $initialOffset = 1000000;

	public $userArray = array();
	public $newUserProps = array();


	public function __construct() {
		parent::__construct();

		$this->mDescription = "This combines all user tables into one. This is potentially very destructive. Make a backup first.";

		// addOption ($name, $description, $required=false, $withArg=false, $shortName=false)
		$this->addOption(
			'prime-wiki',
			'Wiki ID of prime wiki',
			true, true );

		$this->recordTables = $this->tablesToModify; // can't add user_properties, since it gets moved to primewiki

	}


	public function execute() {

		// Perform checks to make sure ready for unification
		$this->checkSetup();

		// ???
		$this->getWikiIDs();

		// make array of all wiki database names + connection configs, including prime wiki
		$this->getWikiDatabaseConfigs();

		// actually get array of database connection objects
		$this->getWikiDBs();

		// ???
		$this->originalUserIDs = $this->getUserIDsByWiki();

		// Record relevant info from all tables for checking later
		$this->recordOriginalIDs();

		// Add $this->initialOffset to all user IDs on all tables on all wikis
		// and delete an unneeded table. Read new IDS into $this->tempUserIDs
		$this->prepDatabases();

		// ???
		$this->temporaryUserIDs = $this->getUserIDsByWiki();

		// Create $this->userArray by reading table `user` from all databases
		// From this array comes the new user IDs for all users
		$this->createUserArray();

		// Update all tables of all wikis with the new user IDs from $this->userArray
		// including primeWiki. Delete user and user_properties tables of all except
		// primeWiki.
		$this->performTableModification();

		// ???
		$this->createUnifiedUserTable();

		// ???
		$this->createUnifiedUserPropertiesTable();

		// Run tests against data recorded prior to ID changes
		$this->testNewIDs();

		// ???
		$this->closeout();

	}

	public function checkSetup () {

		global $m_htdocs, $m_config, $m_meza;

		if ( is_file( "$m_config/local/primewiki" ) ) {
			die( "A prime wiki is already set in $m_config/local/primewiki. You cannot run this script." );
		}

		// prime wiki ID and database name
		$this->primeWiki = trim( $this->getOption( "prime-wiki" ) );

		$this->recordDir = "$m_meza/logs/user-unify-" . date( "YmdHis" );

	}

	public function getWikiIDs () {
		global $m_htdocs;

		// all other wiki IDs
		$wikisDirectory = array_slice( scandir( "$m_htdocs/wikis" ), 2 );
		$this->wikiIDs = array();
		foreach( $wikisDirectory as $fileOrDir ) {
			if ( is_dir( "$m_htdocs/wikis/$fileOrDir" ) ) {
				$this->wikiIDs[] = $fileOrDir;
			}
		}

		return $this->wikiIDs;

	}

	public function getWikiDatabaseConfigs () {
		$this->wikiDatabaseConfigs = array(
			$this->primeWiki => $this->getWikiDbConfig( $this->primeWiki )
		);
		foreach ( $this->wikiIDs as $wikiID ) {
			if ( $wikiID == $this->primeWiki ) {
				continue;
			}
			$this->wikiDatabaseConfigs[$wikiID] = $this->getWikiDbConfig( $wikiID );
		}
		return $this->wikiDatabaseConfigs;
	}

	public function getWikiDBs () {

		$this->wikiDBs = array();
		$this->originalUserIDs = array();
		global $wgDBtype, $wgDBserver;
		foreach( $this->wikiDatabaseConfigs as $wikiID => $conn ) {
			$this->output( "\nConnecting to database $wikiID");
			// $this->wikiDBs[$wiki] = new DB( $wiki );

			$this->wikiDBs[$wikiID] = DatabaseBase::factory(
				$wgDBtype,
				array(
					'host' => $wgDBserver,
					'user' => $conn['user'],
					'password' => $conn['password'],
					'dbname' => $conn['database'],
					'driver' => 'mysqli',
					// 'flags' => , // meza does not currently use this
					// 'tablePrefix' => , // meza does not currently use this
					// 'schema' => , // I think this is only required for MS SQL
				)
			);

		}

	}

	public function getUserIDsByWiki () {

		$usersByWiki = array();

		foreach ( $this->wikiDBs as $wikiID => $db ) {

			$thisWikiUserTable = $db->query( "SELECT user_id, user_name FROM user" );

			$usersByWiki[$wikiID] = array();
			while( $row = $thisWikiUserTable->fetchRow() ) {
				$userName  = $row['user_name'];
				$userID = $row['user_id'];

				$usersByWiki[$wikiID][$userName] = $userID;
			}

		}

		return $usersByWiki;
	}


	/**
	 *  For each database, record each tables unique identifier, initial id,
	 *  and initial username
	 *
	 **/
	public function recordOriginalIDs () {

		// don't love this
		mkdir( $this->recordDir );

		$recordTables = $this->recordTables;

		foreach( $this->wikiDBs as $wikiID => $db ) {

			$this->output( "\n#\n# Recording original info for $wikiID\n#" );

			foreach ( $recordTables as $tableName => $tableInfo ) {

				list( $result, $uniqueFields ) = $this->getRecordSelect( $wikiID, $tableName, false );

				$filetext = '';
				$uniques = array();
				while( $row = $result->fetchRow() ) {
					$uniqueString = $this->getUniqueFieldString( $uniqueFields, $row );
					$filetext .= $uniqueString . "\t" . $row['user_id_number'] . "\t" . $row['user_name_text'] . "\n";
				}
				file_put_contents( "{$this->recordDir}/$wikiID.$tableName", $filetext );

			}

			// FIXME: This doesn't run a test against the ipblock table because it's a unique case
			// and it was difficult to implement and not relevant to the developer who had
			// no rows in his ipblocks table

		}
	}

	// perform database select for recording the pre-modification state
	// which is also used for testing the modifications after the fact
	//
	// NOTE: WE ALWAYS SELECT the username from the user table to make
	// sure we're actually seeing that the user ID is being updated
	// properly
	public function getRecordSelect ( $wikiID, $tableName, $usePrimeWiki ) {

		if ( $usePrimeWiki ) {
			$userTableWiki = $this->primeWiki;
		}
		else {
			$userTableWiki = $wikiID;
		}

		$userTableWikiDB = $this->getWikiDbConfig( $userTableWiki );
		$userTableWikiDB = $userTableWikiDB['database'];


		$tableInfo = $this->recordTables[$tableName];

		$idField = $tableInfo['idField'];
		if ( is_array( $tableInfo['unique'] ) ) {
			$uniqueFields = $tableInfo['unique'];
		}
		else {
			$uniqueFields = array( $tableInfo['unique'] );
		}

		$selectTables = array(
			"t" => $tableName,
			"u" => "$userTableWikiDB.user"
		);
		$selectFields = array(
			'user_id_number' => "t.$idField",
			'user_name_text' => 'u.user_name'
		);

		foreach( $uniqueFields as $key => $field ) {

			// is numeric: field is like `pr_id`
			// else: "unique_username" => "user.user_name"
			if ( is_numeric( $key ) ) {
				$selectFields[$field] = "t.$field";
			}
			else {
				$selectFields[$key] = "u.user_name";
			}
		}

		$result = $this->wikiDBs[$wikiID]->select(
			$selectTables,
			$selectFields,
			array(
				"t.$idField != 0",
				"t.$idField IS NOT NULL"
			),
			__METHOD__,
			null,
			array(
				'u' => array(
					'LEFT JOIN', "u.user_id=t.$idField"
				)
			)
		);

		return array( $result, $uniqueFields );

	}

	// some uniqu
	public function getUniqueFieldString ( $uniqueFields, $row ) {
		foreach( $uniqueFields as $key => $field ) {
			if ( is_numeric( $key ) ) {
				$uniques[] = $row[$field];
			}
			else {
				$uniques[] = $row[$key];
			}
		}
		return implode( ',', $uniques );
	}

	/**
	 *  For each database, add $this->initialOffset to all user IDs in all tables
	 *
	 *  This just makes it so user IDs are always unique
	 *
	 *  Also remove unneeded table
	 *
	 **/
	public function prepDatabases () {
		foreach( $this->wikiDBs as $wikiID => $db ) {

			$this->output( "\n#\n# Adding initial offset to user IDs in $wikiID\n#" );

			$prepTables = $this->tablesToModify
				+ array( "user" => $this->userTable )
				+ array( "user_properties" => $this->userPropsTable );

			foreach ( $prepTables as $tableName => $tableInfo ) {
				$idField = $tableInfo['idField'];
				$db->query( "UPDATE $tableName SET $idField = $idField + $this->initialOffset WHERE $idField != 0 AND $idField IS NOT NULL" );
			}

			$db->query( "UPDATE ipblocks SET ipb_user = ipb_user + $this->initialOffset WHERE ipb_user != 0 AND ipb_user IS NOT NULL");
			$db->query( "UPDATE ipblocks SET ipb_by = ipb_by + $this->initialOffset WHERE ipb_by != 0 AND ipb_by IS NOT NULL");

			// DROP external_user table. See https://www.mediawiki.org/wiki/Manual:External_user_table
			$db->query( "DROP TABLE IF EXISTS external_user" );

		}
	}


	/**
	 *  Create $this->userArray by reading table `user` from all databases
	 *
	 *
	 *
	 **/
	public function createUserArray () {
		$userColumnsIssetChecks = array(
			'user_email',
			'user_real_name',
			'user_password'
		);

		$this->output( "\nCreating userArray from all user tables" );

		// Read user table for all wikis, add to $this->userArray giving each username a new unique ID
		foreach( $this->wikiDBs as $wikiID => $db ) {

			$this->output( "\nAdding $wikiID to userArray" );

			// SELECT entire user table
			$result = $db->query(
				"SELECT * FROM user"
			);

			while( $row = $result->fetchRow() ) {

				if ( ! $this->userTableRows ) {
					$this->userTableRows = array();
					foreach( $row as $key => $value ) {
						$this->userTableRows[] = $key;
					}
				}

				$userName = $row['user_name'];

				if ( ! isset( $this->userArray[$userName] ) ) {

					$this->userArray[$userName] = $row;

					// give new ID
					$newId = count( $this->userArray );

					$this->userArray[$userName]["user_id"] = $newId;

				} else {

					// sum edit counts
					$this->userArray[$userName]["user_editcount"] += $row['user_editcount'];

					// If this wiki ($row) has an older user_registration, use this wiki's value
					if ( $this->userArray[$userName]["user_registration"] > $row['user_registration'] ) {
						$this->userArray[$userName]["user_registration"] = $row['user_registration'];
					}

					// If this wiki ($row) has been touched more recently, use this wiki's value
					if ( $this->userArray[$userName]["user_touched"] < $row['user_touched'] ) {
						$this->userArray[$userName]["user_touched"] = $row['user_touched'];

						// also use this wikis password since they've accessed it more recently
						if ( $row['user_password'] ) {
							$this->userArray[$userName]["user_password"] = $row['user_password'];
						}
					}

					foreach ( $userColumnsIssetChecks as $col ) {
						if ( ! $this->userArray[$userName][$col] && $row[$col] ) {
							$this->userArray[$userName][$col] = $row[$col];
						}
					}

				}
			}

		}

	}


	/**
	 *  For all wikis, make changes to tables with usernames and user IDs
	 *
	 *  Loop through the ~17 tables with usernames and user IDs (except the user
	 *  and user_properties tables) and update them accordingly
	 *
	 *  In the end, only one user and user_properties table will exist across all
	 *  wikis.
	 *
	 **/
	public function performTableModification () {

		$this->output( "\n#\n# Starting major table modifications\n#");
		foreach ( $this->wikiDBs as $wikiID => $db ) {

			$this->output( "\n# Starting major modifications to $wikiID");

			// // For tables with username and id columns: replace the id with the id from $this->userArray
			// foreach( $this->userArray as $userName => $newUserId ) {
			// 	foreach( $tablesWithUsernameAndId as $tableName => $tableInfo ) {
			// 		$idField = $tableInfo['idField'];
			// 		$userNameField = $tableInfo['userNameField'];

			// 		$stmt = $db->mysqli->prepare( "UPDATE $tableName SET $idField=? WHERE $userNameField=?" );
			// 		$stmt->bind_param( 'is', $newUserId, $userName );
			// 		$stmt->execute();
			// 	}
			// }

			// Lookup the ID in the user table, use username to get new ID from $this->userArray, update ID
			// $this->originalUserIDs[$wikiID][$userName] = old user id
			// $thisWikiUserTable = $db->query( "SELECT user_id, user_name FROM user" );
			// print_r( $thisWikiUserTable );

			// $usernameToOldId = array();
			$newIdToOld = array(); // array like $newIdToOld[ newId ] = oldId
			$tempToNew = array(); // opposite of above...

			// foreach( $thisWikiUserTable as $row ) {
			foreach( $this->temporaryUserIDs[$wikiID] as $userName => $tempUserID ) {

				$newUserId = $this->userArray[$userName]['user_id'];

				// quick convert-from-this-to-that arrays
				// $usernameToOldId[$userName] = $tempUserID;
				// $newIdToOld[$newUserId] = $tempUserID;
				$tempToNew[$tempUserID] = $newUserId;


				foreach( $this->tablesToModify as $tableName => $tableInfo ) {
					$idField = $tableInfo['idField'];

					$db->update(
						$tableName,
						array( $idField => $newUserId ), // set values
						array( $idField => $tempUserID ), // conditions: set this where ID field = old value
						__METHOD__
					);

				}

				// fix ipblocks table
				$db->update(
					'ipblocks',
					array( 'ipb_user' => $newUserId ),
					array( 'ipb_user' => $tempUserID ),
					__METHOD__
				);
				$db->update(
					'ipblocks',
					array( 'ipb_by' => $newUserId ),
					array( 'ipb_by' => $tempUserID ),
					__METHOD__
				);
			}


			// Get contents of user_properties, prep for insert into common
			// user_properties table
			$oldUserProps = $db->query( "SELECT * FROM user_properties" );
			// $this->output( "\n\nOLDUSERPROPS:\n");
			// print_r( $oldUserProps );
			// $this->output( "\n\tempToNew:\n");
			// print_r( $tempToNew );

			while( $row = $oldUserProps->fetchRow() ) {
				if ( isset( $tempToNew[ $row['up_user'] ] ) ) {
					$newPropUserId = $tempToNew[ $row['up_user'] ];

					$row['up_user'] = $newPropUserId; // could be dupes across wikis...need to upsert at end
					$this->newUserProps[] = $row;
				} else {
					$oldId = $row['up_user'];
					$this->output( "\nUser ID #$oldId not found in tempToNew array for $wikiID." );
					//$this->output( print_r( array( "id" => $row['up_user'], "array" => $tempToNew ), true ) );
				}
			}

			// Empty the user table for this wiki, since it will just use the common
			// one created at the end. Same for user_properties
			$db->query( "DELETE FROM user" );
			$db->query( "DELETE FROM user_properties" );

			$this->output( "\n# Complete with major modifications to $wikiID" );

		}

		$this->output( "\n# Complete with major modifications to all wikis\n" );

	}

	/**
	 *  Create new user table on the one wiki with the shared user table
	 *
	 *
	 *
	 **/
	public function createUnifiedUserTable () {

		$this->output( "\n# Creating unified user table. \n" );

		$this->userArrayForInsert = array();
		while( $row = array_pop( $this->userArray ) ) {

			$i = count( $this->userArrayForInsert );
			foreach( $this->userTableRows as $key ) {

				// if $key doesn't start with "user_" then skip it (it's not a valid field name)
				if ( strpos( $key, "user_" ) !== 0 ) {
					continue;
				}

				$this->userArrayForInsert[$i][$key] = $row[$key];
			}

		}

		$db = $this->wikiDBs[$this->primeWiki];
		$db->query( 'DELETE FROM user' );
		$db->insert(
			'user',
			$this->userArrayForInsert,
			__METHOD__
		);
		$autoInc = count( $this->userArrayForInsert ) + 1;
		$db->query( "ALTER TABLE user AUTO_INCREMENT = $autoInc;" );

	}


	/**
	 *  Create new user_properties table on the one wiki with the shared user table
	 *
	 *
	 *
	 **/
	public function createUnifiedUserPropertiesTable () {

		$this->output( "\n# Creating unified user_properties table. \n" );

		$this->newUserPropsForInsert = array();
		while( $row = array_pop( $this->newUserProps ) ) {
			$this->newUserPropsForInsert[] = array(
				'up_user'     => $row['up_user'],
				'up_property' => $row['up_property'],
				'up_value'    => $row['up_value'],
			);
		}

		$db = $this->wikiDBs[$this->primeWiki];
		$db->query( 'DELETE FROM user_properties' );
		$db->insert(
			'user_properties',
			$this->newUserPropsForInsert,
			__METHOD__,
			array( 'IGNORE' ) // IGNORE or ON DUPLICATE KEY UPDATE ???
		);

	}

	public function testNewIDs () {

		$this->output( "\nPerforming tests" );

		$recordFiles = scandir( $this->recordDir );
		$logFileSuccess = '';
		$logFileFailure = '';
		foreach ( $recordFiles as $filename ) {
			$filepath = $this->recordDir . "/$filename";
			if ( ! is_file( $filepath ) ) {
				continue;
			}

			$source = explode( '.', $filename );
			$wikiID = $source[0];
			$tableName = $source[1];

			// user_name_text, original_id, some number of unique fields
			list( $result, $uniqueFields ) = $this->getRecordSelect( $wikiID, $tableName, true );

			$tester = array();
			while( $row = $result->fetchRow() ) {
				$uniqueString = $this->getUniqueFieldString( $uniqueFields, $row );
				$tester[$uniqueString] = array(
					'new_user_name' => $row['user_name_text'],
					'new_user_id' => $row['user_id_number']
				);
			}
			unset( $result );

			// loop through all previously recorded rows
			$records = explode("\n", file_get_contents( $filepath ) );
			foreach ( $records as $record ) {
				if ( trim( $record ) == "" ) {
					continue;
				}
				$parts = explode( "\t", $record );
				$unique = $parts[0];
				$originalID = $parts[1];
				$originalUserText = trim( $parts[2] );

				$newUserText = trim( $tester[$unique]['new_user_name'] );
				$newUserID = $tester[$unique]['new_user_id'];

				// check original user not empty, and original user name matches new
				if ( $originalUserText && $originalUserText === $newUserText ) {
					$success = true;
					$successMsg = "[SUCCESS]";
					$this->successes++;
				}
				else {
					$success = false;
					$successMsg = "[FAILURE]";
					$this->failures++;
				}
				$this->totalChecks++;

				$logLine = "$successMsg [$wikiID.$tableName.$unique] [IDs: $originalID --> $newUserID] [Names: $originalUserText --> $newUserText]";
				if ( $success ) {
					$logFileSuccess .= $logLine . "\n";
				}
				else {
					$logFileFailure .= $logLine . "\n";
				}
				//$this->output( "\n$logLine" );
			}

			$s = $this->successes;
			$f = $this->failures;
			$t = $this->totalChecks;
			$this->output( "\nComplete test '$filename'; totals = $s success, $f failures, $t tests so far" );
			file_put_contents( $this->recordDir . '/success.log' , $logFileSuccess, FILE_APPEND );
			file_put_contents( $this->recordDir . '/failure.log' , $logFileFailure, FILE_APPEND );

			$logFileSuccess = '';
			$logFileFailure = '';

		}
		$s = $this->successes;
		$f = $this->failures;
		$t = $this->totalChecks;
		$this->output( "\n\nTESTING COMPLETE! $s success and $f failures of $t total tests" );

	}

	public function closeout () {
		global $m_htdocs, $m_config;

		// Declare the prime-wiki as prime! Write prime wiki's wiki ID to file
		if ( file_put_contents( "$m_config/local/primewiki", $this->primeWiki ) ) {
			$this->output( "\n# Primewiki written to $m_config/local/primewiki\n" );
		}
		else {
			$this->output( "\n# Primewiki not written to $m_config/local/primewiki" );
		}

		// Victory!
		$this->output( "\n#\n# User table unification COMPLETE!\n#\n" );

	}


	// FIXME this belongs in a "Extension:meza" or something
	// this very closely duplicates LocalSettings.php prime wiki check
	protected function getWikiDbConfig ( $wikiID ) {

		global $m_htdocs, $wgDBuser, $wgDBpassword;

		include "$m_htdocs/wikis/$wikiID/config/preLocalSettings.php";

		if ( isset( $mezaCustomDBname ) ) {
			$wikiDBname = $mezaCustomDBname;
		} else {
			$wikiDBname = "wiki_$wikiID";
		}

		$wikiDBuser = isset( $mezaCustomDBuser ) ? $mezaCustomDBuser : $wgDBuser;
		$wikiDBpass = isset( $mezaCustomDBpass ) ? $mezaCustomDBpass : $wgDBpassword;

		return array(
			'id' => $wikiID,
			'database' => $wikiDBname,
			'user' => $wikiDBuser,
			'password' => $wikiDBpass
		);

	}

}
$maintClass = "MezaUnifyUserTables";
require_once( DO_MAINTENANCE );
