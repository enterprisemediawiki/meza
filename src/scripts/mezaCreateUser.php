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
require_once( '/opt/htdocs/mediawiki/maintenance/Maintenance.php' );
class MezaCreateUser extends Maintenance {

	protected $mPassword;
	protected $mEmail;
	protected $mRealName;

	public function __construct() {
		parent::__construct();

		$this->mDescription = "Record the current state of page-watching.";

		// addOption ($name, $description, $required=false, $withArg=false, $shortName=false)
		$this->addOption(
			'username',
			'Choose username',
			false, true );

		$this->addOption(
			'groups',
			'Add user to comma-separated list of groups',
			false, true );

		$this->addOption(
			'email',
			'Set the user\'s email address',
			false, true );

		$this->addOption(
			'password',
			'User\'s password',
			false, true );

		$this->addOption(
			'realname',
			'User\'s real name',
			false, true );
	}

	public function execute() {

		if ( $this->getOption( 'groups' ) ) {
			$this->mGroups = array_map(
				function( $group ){
					// trim any groups with whitespace
					$group = trim( $group );

					// sysop, bot, etc are all lowercase.
					// Prevent accidental capitalization of standard group names.
					$lowerGroup = strtolower( $group );
					if ( $lowerGroup === 'sysop' ) {
						return 'sysop';
					} elseif ( $lowerGroup === 'bureaucrat' ) {
						return 'bureaucrat';
					} elseif ( $lowerGroup === 'bot' ) {
						return 'bot';
					}

					return $group;
				},
				explode( ',', $this->getOption( 'groups' ) ) // make array
			);
		}
		else {
			$this->mGroups = array();
		}

		$newUsername = $this->getOption( 'username' );
		$this->mPassword = $this->getOption( 'password' );
		$this->mEmail    = $this->getOption( 'email' );
		$this->mRealName = $this->getOption( 'realname' );

		$status = $this->createUser( User::newFromName( $newUsername ), false );

		// @fixme: check $status
		$this->output( "\n User $newUsername created \n" );
	}

	/**
	 * Taken from SpecialUserLogin->initUser()
	 *
	 * Actually add a user to the database.
	 * Give it a User object that has been initialised with a name.
	 *
	 * @param $u User object.
	 * @param $autocreate boolean -- true if this is an autocreation via auth plugin
	 * @return Status object, with the User object in the value member on success
	 * @private
	 */
	function createUser( $u, $autocreate ) {
		global $wgAuth;

		$status = $u->addToDatabase();
		if ( !$status->isOK() ) {
			return $status;
		}

		if ( $wgAuth->allowPasswordChange() ) {
			$u->setPassword( $this->mPassword );
		}

		$u->setEmail( $this->mEmail );
		$u->setRealName( $this->mRealName );
		$u->setToken();

		$wgAuth->initUser( $u, $autocreate );

		$u->saveSettings();

		// Update user count
		DeferredUpdates::addUpdate( new SiteStatsUpdate( 0, 0, 0, 0, 1 ) );

		// Watch user's userpage and talk page
		$u->addWatch( $u->getUserPage(), WatchedItem::IGNORE_USER_RIGHTS );

		// added by jamesmontalvo3
		foreach( $this->mGroups as $group ) {
			$u->addGroup( $group );
		}

		return Status::newGood( $u );
	}

}
$maintClass = "MezaCreateUser";
require_once( DO_MAINTENANCE );


