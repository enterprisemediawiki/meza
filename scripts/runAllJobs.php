<?php
/**
 * Wrapper for mediawiki/maintenance/runJobs.php for all wikis
 * Use with cron to run jobs for all wikis periodically
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
 * @author Daren Welsh
 * @ingroup Maintenance
 */
require_once( '/opt/meza/htdocs/mediawiki/maintenance/Maintenance.php' );

class RunAllJobs extends Maintenance {

	public function __construct() {
		parent::__construct();

		$this->mDescription = "Run all jobs for all wikis";

		// addOption ($name, $description, $required=false, $withArg=false, $shortName=false)
		$this->addOption(
			'maxtime',
			'Max execution time PER WIKI',
			false, true );

		$this->addOption(
			'totalmaxtime',
			'Max execution time for the script',
			false, true );

		$this->addOption(
			'maxjobs',
			'Max number of jobs to run PER WIKI',
			false, true );

		$this->addOption(
			'maxload',
			'Max CPU and IO load, above which the script won\'t run',
			false, true );

		$this->addOption(
			'wikis',
			'Wikis from which to run jobs',
			false, true );

	}

	public function execute () {

		$totalmaxtime = (int) $this->getOption( 'totalmaxtime', 0 );
		if ( $totalmaxtime > 0 ) {
			// override default script timeout
			set_time_limit( $totalmaxtime );
		}

		$maxtime = (int) $this->getOption( 'maxtime', 0 );
		$maxtime = $maxtime > 0 ? " --maxtime=$maxtime " : '';

		$maxjobs = (int) $this->getOption( 'maxjobs', 0 );
		$maxjobs = $maxjobs > 0 ? " --maxjobs=$maxjobs " : '';

		$maxload = (float) $this->getOption( 'maxload', 100 ); // default big number, load always lower

		$wikiIds = $this->getOption( 'wikis', false );
		if ( ! $wikiIds ) {
			$wikiIds = scandir( '/opt/meza/htdocs/wikis' );
		}
		else {
			// split comma-separate list of wiki IDs, trim whitespace from each
			$wikiIds = array_map( 'trim', explode( ',', $wikiIds ) );
		}

		global $m_mediawiki;

		// put keys in random order so wikis starting with A don't always get their
		// jobs prioritized over wikis starting with Z.
		shuffle( $wikiIds );

		foreach ($wikiIds as $wikiId) {

			// remove . and .. directories and any files
			if ( $wikiId === '.' || $wikiId === '..' || ! is_dir( $wikiId ) ) {
				continue;
			}

			// see if max load in the last minute is higher than desired to run script
			if ( sys_getloadavg()[0] < $maxload ) {

				echo "Running jobs for $wikiId\n";
				$command = "WIKI=$wikiId php $m_mediawiki/maintenance/runJobs.php $maxtime $maxjobs";
				$output = shell_exec( $command );
				echo $output . "\n";

			}

		}

	}

}
$maintClass = "RunAllJobs";
require_once( DO_MAINTENANCE );
