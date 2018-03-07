<?php
/**
 * This script merges the contents of several wikis into one (blank) wiki
 *
 * It does this by:
 *
 *   (1) Get all pages on all merging wikis
 *       - If same name, not same content:
 *          - Import pages as [[Original page name (WIKI_ID_CAPITALIZED)]]
 *          - Create page [[Original page name]] as disambiguation page
 *            with SMW data pointing to pages for header/footer use
 *       - If same name, same content: For now just pick one and import it
 *       - If not same name: import it normally
 *
 *   (2) NOT IMPLEMENTED: Ideally templates, forms, properties, and categories
 *       would be handled differently. Something like this:
 *
 *       - Templates: For all pages (templates and otherwise) that link to the
 *         template do: \{\{\s*template-name  --> {{template-name (wikiid)
 *
 *       - Forms: Change "for template" to point to new name of templates.
 *         Could be many different templates within an form, and it'll be hard
 *         to bookkeep what templates have new names. Hmm...
 *
 *       - Properties: As long as they have the same type it doesn't really
 *         matter that much. Perhaps check for type, then if same just take
 *         the longest page.
 *
 *       - Categories: Change "Has form" to point to "Form name (new-wiki-id)"
 *         For all pages in the category, as well as the similarly named
 *         template for the category, do find/replace:
 *         \[\[Category:Category name\]\]  -->  [[Category:Category name (wikiId)]]
 *
 *   (3) NOT IMPLEMENTED: Import files to the new wiki
 *
 * Usage:
 *  mergedwiki wiki ID to merge into
 *  sourcewikis: comma-separated list of wiki IDs
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
class UniteTheWikis extends Maintenance {

	protected $mergedwiki;
	protected $sourcewikis;
	protected $fileDisambig;
	protected $fileXml;
	protected $fileMove;
	protected $pages;
	protected $db;
	protected $maintDir;
	protected $maxSimoImport = 100;
	protected $importSetSize = 1000;
	protected $mergeDatabase = "merge_wiki";
	protected $mergeTable = "imports";
	protected $configTable = "config";

	public function __construct () {

		require_once '/opt/.deploy-meza/config.php';

		parent::__construct();
		$this->mDescription = "Count the recent hits for each page.";
		$this->maintDir = "$m_mediawiki/maintenance/";

		$DIR = "/tmp";
		$this->fileDisambig = "$DIR/disambig.mediawiki";
		$this->fileXml = "$DIR/mwTransfer.xml";
		$this->fileMove = "$DIR/mwMovePage.txt";
		$this->fileDumpList = "$DIR/mwDumpList.txt";


		// addOption ($name, $description, $required=false, $withArg=false, $shortName=false)
		$this->addOption(
			'mergedwiki',
			'Which wiki will all the pages be merged into',
			false, true );

		$this->addOption(
			'sourcewikis',
			'Comma separated list of wikis to pull from',
			false, true );

		// whether to delete merge database
		$this->addOption( 'cleanup', 'Sends command to drop temporary database' );

		$this->addOption( 'imports-remaining', 'How many imports left' );

	}

	public function execute () {

		if ( $this->hasOption( 'cleanup' ) ) {
			$this->cleanupDatabase();
		}

		else if ( $this->hasOption( 'imports-remaining' ) ) {
			$this->output( $this->getImportRemaining() );
			return; // don't want the \n at the end of this function
		}

		// if there's already stuff in the merge table, process it
		else if ( $this->checkDB() ) {
			$this->importSet();
		}

		// if not, go pull all the pages to merge from the source wikis
		else {
			$this->getPages();
		}

		$this->output( "\n" ); // basically always want to end with a newline

	}

	protected function config ( $key, $value=null ) {
		// no value passed, getting value
		$dbw = wfGetDB( DB_MASTER );
		if ( $value === null ) {
			$result = $dbw->selectRow(
				"{$this->mergeDatabase}.{$this->configTable}",
				'value',
				array( 'keycolumn' => $key ),
				__METHOD__
			);
			if ( $result ) {
				return $result->value;
			}
			else {
				return false;
			}
		}
		// value passed, setting value
		else {
			return $dbw->insert(
				"{$this->mergeDatabase}.{$this->configTable}",
				array( 'keycolumn' => $key, 'value' => $value ),
				__METHOD__
			);
		}
	}

	protected function setSourceWikis ( $string ) {
		$this->sourcewikis = explode( ',', $string );
	}

	protected function checkDB () {
		$dbw = wfGetDB( DB_MASTER );

		// if DB exists already grab the config from the config table
		if ( $dbw->query( "SHOW DATABASES LIKE \"{$this->mergeDatabase}\"" )->numRows() > 0 ) {
			$this->output( "\nTemporary DB already exists, getting config..." );
			$this->mergedwiki = $this->config( "mergedwiki" );
			$this->setSourceWikis( $this->config( 'sourcewikis' ) );
			return true;
		}

		// if it doesn't exist, create it and the tables
		else {

			$this->mergedwiki = $this->getOption( 'mergedwiki' );
			$this->setSourceWikis( $this->getOption( 'sourcewikis' ) );

			if ( ! $this->mergedwiki || ! $this->sourcewikis ) {
				$this->output( "\n\nFATAL ERROR: you must include both of the following:" );
				$this->output( "\n  --mergedwiki=<wiki ID of wiki you will merge into" );
				$this->output( "\n  --sourcewikis=<comma-separated list of wiki IDs you will pull from" );
				die();
			}

			// database
			$this->output( "\nCreating temporary database." );
			$dbw->query( "CREATE DATABASE IF NOT EXISTS {$this->mergeDatabase}" );

			// merge table (list of imports)
			$this->output( "\nCreating merge table." );
			$dbw->query( "
				CREATE TABLE IF NOT EXISTS `{$this->mergeDatabase}`.`{$this->mergeTable}` (
					`import_id` int unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
					`page_namespace` int NOT NULL,
					`page_title` varchar(255) binary NOT NULL,
					`num_wikis` int NOT NULL,
					`uniques` int NOT NULL,
					`wikis` varchar(255) binary NOT NULL,
					`status` smallint NOT NULL
				) ENGINE=InnoDB, DEFAULT CHARSET=binary;
			" );

			// config table
			$this->output( "\nCreating config table." );
			$dbw->query( "
				CREATE TABLE IF NOT EXISTS `{$this->mergeDatabase}`.`{$this->configTable}` (
					`keycolumn` varchar(255) binary NOT NULL PRIMARY KEY,
					`value` varchar(255) binary NOT NULL
				) ENGINE=InnoDB, DEFAULT CHARSET=binary;
			" );

			// populate config
			$this->config( "mergedwiki", $this->mergedwiki );
			$this->config( "sourcewikis", $this->getOption( 'sourcewikis' ) );

			return false;
		}

	}

	public function dumpPageXML ($pages, $wiki) {
		$this->output( "\nDump $wiki XML\n" );
		unlink( $this->fileDumpList );
		unlink( $this->fileXml );

		if ( is_array($pages) ) {
			$pagelist = implode( "\n", $pages );
		}
		else {
			$pagelist = $pages;
		}
		file_put_contents( $this->fileDumpList, $pagelist );
		shell_exec( "WIKI=$wiki php {$this->maintDir}dumpBackup.php --full --logs --uploads --include-files --pagelist={$this->fileDumpList} > {$this->fileXml}" );
	}

	public function importXML () {
		$this->output( "\nImport XML" );
		shell_exec( "WIKI={$this->mergedwiki} php {$this->maintDir}importDump.php --no-updates --uploads --debug --report=100 < {$this->fileXml}" );
	}

	public function importUniquePages ($pages, $wiki) {
		$this->dumpPageXML( $pages, $wiki );
		$this->importXML();
		return;
	}

	public function importIdenticalPages ($pagename, $wikis) {

		// FIXME
		// For now, don't try to be smart about importing revisions. Ideally this would either:
		//   1. Determine which wiki should be imported based on quantity/age of revisions
		//   2. Smartly merge (and perhaps delete) all revisions from all wikis
		// For now just grab any page, biasing towards the oldest wiki (eva) if available.
		if ( in_array( "eva", $wikis ) ) {
			$this->importUniquePages( $pagename, "eva" );
		}
		else {
			$this->importUniquePages( $pagename, $wikis[0] );
		}

	}

	public function importConflictedPages ($pagename, $wikis) {

		$mergedwiki = $this->mergedwiki;

		$fileDisambig = $this->fileDisambig;
		$fileMove = $this->fileMove;

		$conflictWikis = implode( ', ', $wikis );
		$deconflictMsg = "$conflictWikis all with same page. Deconflicting name $pagename.";
		$disambigMsg = "Generate disambiguation page for conflicting pages on wikis: $conflictWikis";
		$disambigForTemplate = "{{Disambig}}\n\n";

		foreach( $wikis as $wiki ) {
			$wikiForTitle = strtoupper( $wiki );
			$this->dumpPageXML( $pagename, $wiki );
			$this->importXML();

			unlink( $fileMove );
			file_put_contents( $fileMove, "$pagename|$pagename ($wikiForTitle)" );
			shell_exec( "WIKI=$mergedwiki php {$this->maintDir}moveBatch.php --noredirects -r \"$deconflictMsg\" $fileMove" );

			$disambigForTemplate .= "* [[$pagename/$wikiForTitle]]\n";
		}

		// $disambigForTemplate .= "}}";
		file_put_contents( "$fileDisambig", $disambigForTemplate );
		shell_exec( "WIKI=$mergedwiki php {$this->maintDir}edit.php -s \"$disambigMsg\" \"$pagename\" < $fileDisambig" );

		return;

	}

	public function getPages () {

		foreach( $this->sourcewikis as $wiki ) {
			$sqlParts[] = "
				SELECT
					\"$wiki\" AS wiki,
					page_namespace,
					page_title,
					md5( old_text ) AS texthash
				FROM wiki_$wiki.page AS p
				LEFT JOIN wiki_$wiki.revision AS r ON (r.rev_id = p.page_latest)
				LEFT JOIN wiki_$wiki.text AS t ON (t.old_id = r.rev_text_id)
			";
		}

		$union = implode( "\nUNION ALL\n", $sqlParts );

		// the ORDER BY is key for optimizing speed:
		// 1) we want the high namespaces first (properties, forms, templates)
		//    so they are in the wiki before the pages that use them (otherwise
		//    I think it may spawn additional jobs)
		// 2) sort by number of wikis. sort order doesn't really matter, but we
		//    want all the num_wikis=1 cases to be together so they can be put
		//    into bulk imports (can't export from multiple wikis in bulk, thus
		//    can't create an import XML file to import in bulk)
		// 3) sort by wiki so pages from the same wiki are grouped together, so
		//    a bulk export/import can be done
		$query = "
			SELECT
				page_namespace,
				page_title,
				COUNT( * ) AS num_wikis,
				COUNT( distinct texthash ) AS uniques,
				GROUP_CONCAT(wiki) AS wikis
			FROM (
				$union
			) AS tmp
			GROUP BY page_namespace, page_title
			ORDER BY page_namespace DESC, num_wikis ASC, wiki";

		// echo $query;

		$dbw = wfGetDB( DB_MASTER );
		$result = $dbw->query( $query );

		$inserts = array();

		while( $row = $result->fetchRow() ) {

			// need to remove numeric keys, else insert below fails
			foreach ($row as $key => $val) {
				if ( is_numeric($key) ) {
					unset( $row[$key] );
				}
			}
			$row['status'] = 0; // status of zero = not started

			$inserts[] = $row;

			if ( count($inserts) > 19 ) {
				$dbw->insert(
					$this->mergeDatabase . '.' . $this->mergeTable,
					$inserts,
					__METHOD__
				);
				$inserts = array();
			}
		}

		// $dbw->query( "INSERT INTO {$this->mergeDatabase}.{$this->mergeTable}
		// 	(page_namespace, page_title, num_wikis, uniques, wikis)
		// 	VALUES
		// 	()
		// 	"
		// );
		// `insert_id` int unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
		// `page_namespace` int NOT NULL,
		// `page_title` varchar(255) binary NOT NULL,
		// `num_wikis` int NOT NULL,
		// `uniques` int NOT NULL,
		// `wikis` varchar(255) binary NOT NULL,

		$this->importSet();

	}


	protected function importSet () {

		$dbr = wfGetDB( DB_SLAVE );
		$dbNameAndTable = "{$this->mergeDatabase}.{$this->mergeTable}";

		$query = "SELECT import_id FROM $dbNameAndTable ORDER BY import_id DESC LIMIT 1";
		$totalNumRows = $dbr->query( $query )->fetchObject()->import_id;

		$query = "SELECT * FROM $dbNameAndTable
			WHERE status = 0 ORDER BY import_id ASC
			LIMIT {$this->importSetSize}";
		$result = $dbr->query( $query );

		$importQueue = array();
		$count = 0;

		while( $page = $result->fetchObject() ) {

			// On first page print the ID with a big header
			if ( $count === 0 ) {
				$this->output( "\nStarting import at ID = " . $page->import_id . "\n===============================\n" );
			}
			$count++;

			// On each page print the ID and other info
			$percent = round( ($page->import_id / $totalNumRows) * 100, 3 ) . "%";
			$this->output( "\nRow {$page->import_id} of $totalNumRows ($percent). Wikis=" . $page->wikis
				. "; NS=" . $page->page_namespace
				. "; title=" . $page->page_title );

			// get the current wiki being put into the queue. If the queue has
			// pages in it, grab the `wikis` property of any page (they're all
			// the same). If the queue is empty, set the queue-wiki to the wiki
			// of the current loop
			$importQueueWiki = count($importQueue) > 0 ? $importQueue[0]->wikis : $page->wikis;


			// If page is in a single wiki, current queue is set for that wiki,
			// and queue hasn't reached max length: add page to queue.
			if ( intval($page->num_wikis) === 1 && $importQueueWiki === $page->wikis && count($importQueue) < $this->maxSimoImport ) {
				$this->output( "\n  --> Queue" );
				$importQueue[] = $page;
			}

			// Else: (1) process queue as required and (2) import the current
			// page (alternatively could add that page to the queue, to be
			// processed on the next pass)
			else {
				// Import the pages in the queue and clear it
				if ( count( $importQueue ) > 0 ) {
					$this->output( "\n\nProcess queue..." );
					$this->handleImport( $importQueue );
					$importQueue = array();
				}

				// Do this import
				$this->output( "\nHandling import for page " . $page->page_title );
				$this->handleImport( $page );
			}
		}

		// if the while-loop ended with some in the queue, import them
		if ( $importQueue !== null ) {
			$this->handleImport( $importQueue );
		}

		$this->doCompletionCheck();

		return;

	}

	/**
	 * $pages is either:
	 *
	 *	$page object with $page->page_title, $page->wikis, etc ($page being an
	 *  object representation of a row from $this->mergeTable)
	 *
	 *  - OR -
	 *
	 *  array( $page1, $page2, $page3, ... )
	 *
	 **/
	public function handleImport ( $pages ) {

		$importIDs = array();

		// Determine if this is multiple pages or just one
		if ( is_array($pages) && count($pages) > 1 ) {

			// if multiple pages, they'll all be from the same wiki (so create
			// an array with just this wiki in it, rather than the exploded
			// comma-separated-list of wikis below)
			$wikis = array( $pages[0]->wikis );

			// ??
			$pageTitleText = array();

			$this->output( "\nImporting multiple pages from " . $pages[0]->wikis . ": ");


			foreach( $pages as $page ) {

				// Make a MediaWiki Title object in order to get the full text
				//of the page, then put that text in an array for later use as
				// indicating what to import
				$pageTitleObj = Title::makeTitle( $page->page_namespace, $page->page_title );
				$text = $pageTitleObj->getFullText();
				$pageTitleText[] = $text;
				$importIDs[] = $page->import_id;
				$this->output( "\n  * $text" );
			}
		}
		else {
			if ( is_array($pages) && count($pages) === 1 ) {
				$pages = $pages[0];
			}
			else if ( is_array($pages) ) {
				$this->output( "\n\n\n\n  ## ERROR: Array when object expected. Array length = " . count($pages) );
				$this->output( "\n\n  ## This may mean all pages have been processed. Array print_r output below: " );
				$this->output( "\n\n" . print_r( $pages, true ) );
				return;
			}
			$wikis = explode( ",", $pages->wikis );
			$pageTitleObj = Title::makeTitle( $pages->page_namespace, $pages->page_title );
			$pageTitleText = $pageTitleObj->getFullText();
			$importIDs[] = $pages->import_id;
			$this->output( "\nImporting page $pageTitleText from " . $pages->wikis );
		}

		// ASDF left off here FIXME
		if ( count( $wikis ) === 1 ) {
			$this->output( "\n\nImport unique page(s)\n" );
			$this->importUniquePages( $pageTitleText, $wikis[0] );
		}
		else if ( intval( $pages->uniques ) === 1 ) {
			$this->output( "\n\nImport identical pages\n" );
			$this->importIdenticalPages( $pageTitleText, $wikis );
		}
		else {
			$this->output( "\n\nImport conflicted pages\n" );
			$this->importConflictedPages( $pageTitleText, $wikis );
		}

		$this->markImportsComplete( $importIDs );

	}

	protected function markImportsComplete ( $importIDs ) {
		$dbw = wfGetDB( DB_MASTER );
		$dbw->update(
			"{$this->mergeDatabase}.{$this->mergeTable}",
			array( "status" => 1 ),
			array( "import_id" => $importIDs )
		);
	}

	protected function anythingInDB () {
		$dbw = wfGetDB( DB_MASTER );

		// if there's already stuff in the merge table...
		if ( $dbw->query( "SELECT * FROM {$this->mergeDatabase}.{$this->mergeTable} LIMIT 1" )->numRows() > 0 ) {
			return true;
		}
		else {
			return false;
		}
	}

	protected function doCompletionCheck () {

		if ( ! $this->anythingInDB() ) {
			$this->output( "\n\nMERGE COMPLETE" );
		}
		else {
			$this->output( "\n\n{$this->importSetSize} items processed. Items still remain." );
		}

	}

	protected function getImportRemaining () {
		$dbw = wfGetDB( DB_MASTER );
		return $dbw->selectField(
			"{$this->mergeDatabase}.{$this->mergeTable}",
			"COUNT(*)",
			array( 'status' => 0 ),
			__METHOD__
		);
	}

	protected function cleanupDatabase () {
		$dbw = wfGetDB( DB_MASTER );
		$this->output( "\nCleaning up database...");
		$dbw->query( "DROP DATABASE {$this->mergeDatabase}" );
		$this->output( "\ndone." );
	}

}

$maintClass = "UniteTheWikis";
require_once( DO_MAINTENANCE );
