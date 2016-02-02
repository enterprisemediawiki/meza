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

		global $m_htdocs;

		if ( is_file( "$m_htdocs/__common/primewiki" ) ) {
			die( "A prime wiki is already set in $m_htdocs/__common/primewiki. You cannot run this script." );
		}

		// prime wiki ID and database name
		$primeWiki = trim( $this->getOption( "prime-wiki" ) );

		// all other wiki IDs
		$wikisDirectory = array_slice( scandir( "$m_htdocs/wikis" ), 2 );
		$wikiIDs = array();
		foreach( $wikisDirectory as $fileOrDir ) {
			if ( is_dir( "$m_htdocs/wikis/$fileOrDir" ) ) {
				$wikiIDs[] = $fileOrDir;
			}
		}
		unset( $wikisDirectory );


		// make array of all wiki database names, including prime wiki

		$wikiDBconnections[$primeWiki] = $this->getWikiDbConfig( $primeWiki );
		foreach ( $wikiIDs as $wikiID ) {
			$wikiDBconnections[$wikiID] = $this->getWikiDbConfig( $wikiID );
		}

		// FIXME: make the script check for the largest value
		$initialOffset = 10000; // make sure this is larger than your largest user ID


		// $idAndNameTables = array(
		// 	"archive"       => array( "idField" => "ar_user",  "userNameField" => "ar_user_text" ),
		// 	"filearchive"   => array( "idField" => "fa_user",  "userNameField" => "fa_user_text" ),
		// 	"image"         => array( "idField" => "img_user", "userNameField" => "img_user_text" ),
		// 	"logging"       => array( "idField" => "log_user", "userNameField" => "log_user_text" ),
		// 	"oldimage"      => array( "idField" => "oi_user",  "userNameField" => "oi_user_text" ),
		// 	"recentchanges" => array( "idField" => "rc_user",  "userNameField" => "rc_user_text" ),
		// 	"revision"      => array( "idField" => "rev_user", "userNameField" => "rev_user_text" ),
		// );


		$userTable = array( "idField" => "user_id", "userNameField" => "user_name" );

		$userColumnInfo = array(
			'user_name'         => 'b',
			'user_editcount'    => 'i',
			'user_touched'      => 'b',
			'user_registration' => 'b',
			'user_email'        => 'b',
			'user_real_name'    => 'b',
		);


		$tablesToModify = array(
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


		$wikiDBs = array();
		$originalUserIDs = array();
		global $wgDBtype, $wgDBserver;
		foreach( $wikiDBconnections as $wikiID => $conn ) {
			$this->output( "\nConnecting to database $wiki");
			// $wikiDBs[$wiki] = new DB( $wiki );

			$wikiDBs[$wikiID] = DatabaseBase::factory(
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

			$db = $wikiDBs[$wikiID];

			$thisWikiUserTable = $db->query( "SELECT user_id, user_name FROM user" );

			$originalUserIDs[$wikiID] = array();
			while( $row = $thisWikiUserTable->fetchRow() ) {
				$userName  = $row['user_name'];
				$oldUserId = $row['user_id'];

				$originalUserIDs[$wikiID][$userName] = $oldUserId;
			}

		}






		/**
		 *  For each database, add $initialOffset to all user IDs in all tables
		 *
		 *  This just makes it so user IDs are always unique
		 *
		 *  Also remove unneeded table
		 *
		 **/
		foreach( $wikiDBs as $wikiID => $db ) {

			$this->output( "\n#\n# Adding initial offset to user IDs in $wikiID\n#" );

			foreach ( $tablesToModify + array( "user" => $userTable ) as $tableName => $tableInfo ) {
				$idField = $tableInfo['idField'];
				$db->query( "UPDATE $tableName SET $idField = $idField + $initialOffset" );
			}

			$db->query( "UPDATE ipblocks SET ipb_user = ipb_user + $initialOffset, ipb_by = ipb_by + $initialOffset");

			// DROP external_user table. See https://www.mediawiki.org/wiki/Manual:External_user_table
			$db->query( "DROP TABLE IF EXISTS external_user" );

		}




		/**
		 *  Create $userArray by reading table `user` from all databases
		 *
		 *
		 *
		 **/
		$userArray = array();
		$newUserProps = array();
		$userColumnsIssetChecks = array(
			'user_email',
			'user_real_name',
		);

		$this->output( "\nCreating userArray from all user tables" );

		// Read user table for all wikis, add to $userArray giving each username a new unique ID
		foreach( $wikiDBs as $wikiID => $db ) {

			$this->output( "\nAdding $wikiID to userArray" );

			// SELECT entire user table
			$userColumns = implode( ',', array_keys( $userColumnInfo ) );
			$result = $db->query(
				"SELECT $userColumns FROM user"
			);

			while( $row = $result->fetchRow() ) {

				$userName = $row['user_name'];

				if ( ! isset( $userArray[$userName] ) ) {

					$userArray[$userName] = $row;

					// give new ID
					$newId = count( $userArray );

					$userArray[$userName]["user_id"] = $newId;

				} else {

					// sum edit counts
					$userArray[$userName]["user_editcount"] += $row['user_editcount'];

					// If this wiki ($row) has an older user_registration, use this wiki's value
					if ( $userArray[$userName]["user_registration"] > $row['user_registration'] ) {
						$userArray[$userName]["user_registration"] = $row['user_registration'];
					}

					// If this wiki ($row) has been touched more recently, use this wiki's value
					if ( $userArray[$userName]["user_touched"] < $row['user_touched'] ) {
						$userArray[$userName]["user_touched"] = $row['user_touched'];
					}

					foreach ( $userColumnsIssetChecks as $col ) {
						if ( ! $userArray[$userName][$col] ) {
							$userArray[$userName][$col] = $row[$col];
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
		$this->output( "\n#\n# Starting major table modifications\n#");
		foreach ( $wikiDBs as $wikiID => $db ) {

			$this->output( "\n# Starting major modifications to $wikiID");

			// // For tables with username and id columns: replace the id with the id from $userArray
			// foreach( $userArray as $userName => $newUserId ) {
			// 	foreach( $tablesWithUsernameAndId as $tableName => $tableInfo ) {
			// 		$idField = $tableInfo['idField'];
			// 		$userNameField = $tableInfo['userNameField'];

			// 		$stmt = $db->mysqli->prepare( "UPDATE $tableName SET $idField=? WHERE $userNameField=?" );
			// 		$stmt->bind_param( 'is', $newUserId, $userName );
			// 		$stmt->execute();
			// 	}
			// }

			// Lookup the ID in the user table, use username to get new ID from $UserArray, update ID
			// $originalUserIDs[$wikiID][$userName] = old user id
			// $thisWikiUserTable = $db->query( "SELECT user_id, user_name FROM user" );
			// print_r( $thisWikiUserTable );

			$usernameToOldId = array();
			$newIdToOld = array(); // array like $newIdToOld[ newId ] = oldId
			$oldIdToNew = array(); // opposite of above...

			// foreach( $thisWikiUserTable as $row ) {
			foreach( $originalUserIDs[$wikiID] as $userName => $oldUserId ) {

				$info = $userArray[$userName];
				$newUserId = $info['user_id'];

				// quick convert-from-this-to-that arrays
				$usernameToOldId[$userName] = $oldUserId;
				// $newIdToOld[$newUserId] = $oldUserId;
				$oldIdToNew[$oldUserId] = $newUserId;


				foreach( $tablesToModify as $tableName => $tableInfo ) {
					$idField = $tableInfo['idField'];

					$db->update(
						$tableName,
						array( $idField => $newUserId ), // set values
						array( $idField => $oldUserId ), // conditions: set this where ID field = old value
						__METHOD__
					);

				}

				// fix ipblocks table
				$db->update(
					'ipblocks',
					array( 'ipb_user' => $newUserId ),
					array( 'ipb_user' => $oldUserId ),
					__METHOD__
				);
				$db->update(
					'ipblocks',
					array( 'ipb_by' => $newUserId ),
					array( 'ipb_by' => $oldUserId ),
					__METHOD__
				);
			}


			// Get contents of user_properties, prep for insert into common
			// user_properties table
			$oldUserProps = $db->query( "SELECT * FROM user_properties" );
			// $this->output( "\n\nOLDUSERPROPS:\n");
			// print_r( $oldUserProps );
			// $this->output( "\n\oldIdToNew:\n");
			// print_r( $oldIdToNew );

			while( $row = $oldUserProps->fetchRow() ) {
				if ( isset( $oldIdToNew[ $row['up_user'] ] ) ) {
					$newPropUserId = $oldIdToNew[ $row['up_user'] ];

					$row['up_user'] = $newPropUserId; // could be dupes across wikis...need to upsert at end
					$newUserProps[] = $row;
				} else {
					$oldId = $row['up_user'];
					$this->output( "\nUser ID #$oldId not found in oldIdToNew array for $wikiID.");
					//$this->output( print_r( array( "id" => $row['up_user'], "array" => $oldIdToNew ), true ) );
				}
			}

			// Empty the user table for this wiki, since it will just use the common
			// one created at the end. Same for user_properties
			//$db->query( "DELETE FROM user" );
			//$db->query( "DELETE FROM user_properties" );

		}




		/**
		 *  Create new user table on the one wiki with the shared user table
		 *
		 *
		 *
		 **/
		$userArrayForInsert = array();
		while( $row = array_pop( $userArray ) ) {
			$userArrayForInsert[] = array(
				'user_name'         => $row['user_name'],
				'user_editcount'    => $row['user_editcount'],
				'user_touched'      => $row['user_touched'],
				'user_registration' => $row['user_registration'],
				'user_email'        => $row['user_email'],
				'user_real_name'    => $row['user_real_name'],
				'user_id'           => $row['user_id'],
			);
		}

		$db = $wikiDBs[$primeWiki];
		$db->query( 'DELETE FROM user' );
		$db->insert(
			'user',
			$userArrayForInsert,
			__METHOD__
		);
		$autoInc = count( $userArrayForInsert ) + 1;
		$db->query( "ALTER TABLE user AUTO_INCREMENT = $autoInc;" );




		/**
		 *  Create new user_properties table on the one wiki with the shared user table
		 *
		 *
		 *
		 **/
		$newUserPropsForInsert = array();
		while( $row = array_pop( $newUserProps ) ) {
			$newUserPropsForInsert[] = array(
				'up_user'     => $row['up_user'],
				'up_property' => $row['up_property'],
				'up_value'    => $row['up_value'],
			);
		}

		$db->query( 'DELETE FROM user_properties' );
		$db->insert(
			'user_properties',
			$newUserPropsForInsert,
			__METHOD__,
			array( 'IGNORE' ) // IGNORE or ON DUPLICATE KEY UPDATE ???
		);


		# Declare the prime-wiki as prime! Write prime wiki's wiki ID to file
		file_put_contents( "$m_htdocs/__common/primewiki", $primewiki );

		$this->output( "\n#\n# SCRIPT COMPLETE\n#" ); //end of script

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
