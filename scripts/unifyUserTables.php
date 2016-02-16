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

	public $tablesToModify = array(
		"page_restrictions"  => array( "idField" => "pr_user" ),
		"protected_titles"   => array( "idField" => "pt_user" ),
		"uploadstash"        => array( "idField" => "us_user" ),
		"user_former_groups" => array( "idField" => "ufg_user" ),
		"user_groups"        => array( "idField" => "ug_user" ),
		"user_newtalk"       => array( "idField" => "user_id" ),
		"watchlist"          => array( "idField" => "wl_user" ),

		// these have IDs and usernames, but usernames should not need to be modified or used
		"archive"       => array( "idField" => "ar_user",  "userNameField" => "ar_user_text" ),
		"filearchive"   => array( "idField" => "fa_user",  "userNameField" => "fa_user_text" ),
		"image"         => array( "idField" => "img_user", "userNameField" => "img_user_text" ),
		"logging"       => array( "idField" => "log_user", "userNameField" => "log_user_text" ),
		"oldimage"      => array( "idField" => "oi_user",  "userNameField" => "oi_user_text" ),
		"recentchanges" => array( "idField" => "rc_user",  "userNameField" => "rc_user_text" ),
		"revision"      => array( "idField" => "rev_user", "userNameField" => "rev_user_text" ),

		// extension tables
		'watch_tracking_user' => array( "idField" => 'user_id' ),
		// 'wiretap'             => array( "idField" => NONE, username only )

	);

	// $idAndNameTables = array(
	// 	"archive"       => array( "idField" => "ar_user",  "userNameField" => "ar_user_text" ),
	// 	"filearchive"   => array( "idField" => "fa_user",  "userNameField" => "fa_user_text" ),
	// 	"image"         => array( "idField" => "img_user", "userNameField" => "img_user_text" ),
	// 	"logging"       => array( "idField" => "log_user", "userNameField" => "log_user_text" ),
	// 	"oldimage"      => array( "idField" => "oi_user",  "userNameField" => "oi_user_text" ),
	// 	"recentchanges" => array( "idField" => "rc_user",  "userNameField" => "rc_user_text" ),
	// 	"revision"      => array( "idField" => "rev_user", "userNameField" => "rev_user_text" ),
	// );


	public $userTable = array( "idField" => "user_id", "userNameField" => "user_name" );
	public $userPropsTable = array( "idField" => "up_user" );

	public $userTableRows = false;

	// FIXME: make the script check for the largest value
	public $initialOffset = 10000; // make sure this is larger than your largest user ID

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

		// ???
		$this->closeout();

	}

	public function checkSetup () {

		global $m_htdocs;

		if ( is_file( "$m_htdocs/__common/primewiki" ) ) {
			die( "A prime wiki is already set in $m_htdocs/__common/primewiki. You cannot run this script." );
		}

		// prime wiki ID and database name
		$this->primeWiki = trim( $this->getOption( "prime-wiki" ) );

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
				$db->query( "UPDATE $tableName SET $idField = $idField + $this->initialOffset" );
			}

			$db->query( "UPDATE ipblocks SET ipb_user = ipb_user + $this->initialOffset, ipb_by = ipb_by + $this->initialOffset");

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

	public function closeout () {
		global $m_htdocs;

		// Declare the prime-wiki as prime! Write prime wiki's wiki ID to file
		if ( file_put_contents( "$m_htdocs/__common/primewiki", $this->primeWiki ) ) {
			$this->output( "\n# Primewiki written to $m_htdocs/__common/primewiki\n" );
		}
		else {
			$this->output( "\n# Primewiki not written to $m_htdocs/__common/primewiki" );
		}

		// Victory!
		$this->output( "\n#\n# User table unification COMPLETE!\n#\n" );

	}


	// FIXME this belongs in a "Extension:meza" or something
	// this very closely duplicates LocalSettings.php prime wiki check
	protected function getWikiDbConfig ( $wikiID ) {

		global $m_htdocs, $wgDBuser, $wgDBpassword;

		include "$m_htdocs/wikis/$wikiID/config/setup.php";

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
