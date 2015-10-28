<?php

/**
 * May want to include ParserFunctionHelper in order to extension-ify templates
 */
// 'ParserFunctionHelper' => array(
// 	'git' => 'https://github.com/enterprisemediawiki/ParserFunctionHelper.git',
// 	'branch' => 'master',
// ),

/**
 * ImportUsers is not in wikimedia git, now in github/kghbln. Also, it seems it
 * may not work well with newer versions of MW
 * @url: https://github.com/kghbln/ImportUsers
 * Consider updating and taking into EMW.org
 */
// 'ImportUsers' => array(
// 	'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/ImportUsers.git',
// 	'branch' => 'master',
// 	'globals' => array(
// 		'wgShowExceptionDetails' => true,
// 	)
// ),

/**
 * Do we want to install this? Not used much with SMW...
 */
// 'DynamicPageList' => array(
// 	'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/DynamicPageList.git',
// 	'branch' => 'REL1_25',
// ),

$egExtensionLoaderConfig += array(

	'ParserFunctions' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/ParserFunctions.git',
		'branch' => 'REL1_25',
		'globals' => array(
			'wgPFEnableStringFunctions' => true,
		),
	),

	'StringFunctionsEscaped' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/StringFunctionsEscaped.git',
		'branch' => 'REL1_25',
	),

	'ExternalData' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/ExternalData.git',
		'branch' => 'REL1_25',
	),

	'LabeledSectionTransclusion' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/LabeledSectionTransclusion.git',
		'branch' => 'REL1_25',
	),

	'Cite' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/Cite.git',
		'branch' => 'REL1_25',
		'globals' => array(
			'wgCiteEnablePopups' => true,
		),
	),

	// managed by composer due to use of SemanticMeetingMinutes
	// 'HeaderFooter' => array(
	// 	'git' => 'https://github.com/enterprisemediawiki/HeaderFooter.git',
	// 	'branch' => 'master',
	// ),

	'WhoIsWatching' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/WhoIsWatching.git',
		'branch' => 'REL1_25',
		'globals' => array(
			'wgPageShowWatchingUsers' => true,
		),
	),

	'CharInsert' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/CharInsert.git',
		'branch' => 'REL1_25',
	),

	'SemanticForms' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/SemanticForms.git',
		'branch' => 'REL1_25',
	),

	'SemanticInternalObjects' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/SemanticInternalObjects.git',
		'branch' => 'REL1_25',
	),

	'SemanticCompoundQueries' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/SemanticCompoundQueries.git',
		'branch' => 'REL1_25',
	),

	'Arrays' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/Arrays.git',
		'branch' => 'REL1_25',
	),

	'TitleKey' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/TitleKey.git',
		'branch' => 'REL1_25',
	),

	'TalkRight' => array(
		'git' => 'https://github.com/enterprisemediawiki/TalkRight.git',
		'branch' => 'master',
	),

	'AdminLinks' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/AdminLinks.git',
		'branch' => 'REL1_25',
		'afterFn' => function() {
			$GLOBALS['wgGroupPermissions']['sysop']['adminlinks'] = true;
		}
	),

	'DismissableSiteNotice' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/DismissableSiteNotice.git',
		'branch' => 'REL1_25',
	),

	'BatchUserRights' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/BatchUserRights.git',
		'branch' => 'REL1_25',
	),


	'HeaderTabs' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/HeaderTabs.git',
		'branch' => 'REL1_25',
		'globals' => array(
			'htEditTabLink' => false,
			'htRenderSingleTab' => true,
		)
	),

	'WikiEditor' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/WikiEditor.git',
		'branch' => 'REL1_25',
		'afterFn' => function() {
			$GLOBALS['wgDefaultUserOptions']['usebetatoolbar'] = 1;
			$GLOBALS['wgDefaultUserOptions']['usebetatoolbar-cgd'] = 1;
			# displays publish button
			$GLOBALS['wgDefaultUserOptions']['wikieditor-publish'] = 1;
			# Displays the Preview and Changes tabs
			$GLOBALS['wgDefaultUserOptions']['wikieditor-preview'] = 1;
		}
	),

	'CopyWatchers' => array(
		'git' => 'https://github.com/jamesmontalvo3/MediaWiki-CopyWatchers.git',
		'branch' => 'master',
	),

	// consider replacing with SyntaxHighlight_Pygments
	// https://gerrit.wikimedia.org/r/mediawiki/extensions/SyntaxHighlight_Pygments.git
	'SyntaxHighlight_GeSHi' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/SyntaxHighlight_GeSHi.git',
		'branch' => 'REL1_25',
	),

	'Wiretap' => array(
		'git' => 'https://github.com/enterprisemediawiki/Wiretap.git',
		'branch' => 'master',
	),

	'ApprovedRevs' => array(
		'git' => 'https://github.com/jamesmontalvo3/MediaWiki-ApprovedRevs.git',
		'branch' => 'master',
		'globals' => array(
			'egApprovedRevsAutomaticApprovals' => false,
		),
	),

	'InputBox' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/InputBox.git',
		'branch' => 'REL1_25',
	),

	'ReplaceText' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/ReplaceText.git',
		'branch' => 'REL1_25',
	),

	'Interwiki' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/Interwiki.git',
		'branch' => 'REL1_25',
		'afterFn' => function() {
			$GLOBALS['wgGroupPermissions']['sysop']['interwiki'] = true;
		}
	),

	'IMSQuery' => array(
		'git' => 'https://github.com/jamesmontalvo3/IMSQuery.git',
		'branch' => 'master',
	),

	'MasonryMainPage' => array(
		'git' => 'https://github.com/enterprisemediawiki/MasonryMainPage.git',
		'branch' => 'master',
	),

	'WatchAnalytics' => array(
		'git' => 'https://github.com/enterprisemediawiki/WatchAnalytics.git',
		'branch' => 'master',
		'globals' => array(
			'egPendingReviewsEmphasizeDays' => 10, // makes Pending Reviews shake after X days
		),
	),

	// managed by composer due to use of SemanticMeetingMinutes
	// 'NumerAlpha' => array(
	// 	'git' => 'https://github.com/jamesmontalvo3/NumerAlpha.git',
	// 	'branch' => 'master',
	// ),

	'Variables' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/Variables.git',
		'branch' => 'REL1_25',
	),

	'SummaryTimeline' => array(
		'git' => 'https://github.com/darenwelsh/SummaryTimeline.git',
		'branch' => 'master',
	),

	'YouTube' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/YouTube.git',
		'branch' => 'REL1_25',
	),

	'ContributionScores' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/ContributionScores.git',
		'branch' => 'REL1_25',
		'afterFn' => function() {
			$GLOBALS['wgContribScoreIgnoreBots'] = true;          // Exclude Bots from the reporting - Can be omitted.
			$GLOBALS['wgContribScoreIgnoreBlockedUsers'] = true;  // Exclude Blocked Users from the reporting - Can be omitted.
			$GLOBALS['wgContribScoresUseRealName'] = true;        // Use real user names when available - Can be omitted. Only for MediaWiki 1.19 and later.
			$GLOBALS['wgContribScoreDisableCache'] = false;       // Set to true to disable cache for parser function and inclusion of table.
			//Each array defines a report - 7,50 is "past 7 days" and "LIMIT 50" - Can be omitted.
			$GLOBALS['wgContribScoreReports'] = array(
			    array(7,50),
			    array(30,50),
			    array(0,50));
		}
	),

	/**
	 * In SVN, see https://www.mediawiki.org/wiki/Extension:Pipe_Escape
	 * Do we use this? If so, should we migrate into EMW git?
	 */
	'PipeEscape' => array(
		'git' => 'https://github.com/jamesmontalvo3/MediaWiki-PipeEscape.git',
		'branch' => 'master',
	),

	'PdfHandler' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/PdfHandler',
		'branch' => 'REL1_25',
		'afterFn' => function(){
			// Location of PdfHandler dependencies
			$GLOBALS['wgPdfProcessor'] = '/usr/bin/gs'; // installed via yum
			$GLOBALS['wgPdfPostProcessor'] = '/usr/local/bin/convert'; // built from source
			$GLOBALS['wgPdfInfo'] = '/usr/local/bin/pdfinfo'; // pre-built binaries installed
		}
	),

	'UploadWizard' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/UploadWizard',
		'branch' => 'REL1_25',
		'afterFn' => function(){
			// Location of PdfHandler dependencies
			$GLOBALS['wgEnableUploads'] = true;
			$GLOBALS['wgUseImageMagick'] = true;
			$GLOBALS['wgImageMagickConvertCommand'] = '/usr/local/bin/convert';  # Only needs to be set if different from /usr/bin/convert
			// Needed to make UploadWizard work in IE, see bug 39877
			$GLOBALS['wgApiFrameOptions'] = 'SAMEORIGIN';
		}
	),

	/**
	 * Extensions for Visual Editor
	 **/
	'UniversalLanguageSelector' => array(
		'git' => 'https://gerrit.wikimedia.org/r/p/mediawiki/extensions/UniversalLanguageSelector.git',
		'branch' => 'REL1_25',
	),
	'VisualEditor' => array(
		'git' => 'https://gerrit.wikimedia.org/r/p/mediawiki/extensions/VisualEditor.git',
		'branch' => 'REL1_25',
		'afterFn' => function() {
			global $wikiId;

			// Allow read and edit permission for requests from the server (e.g. Parsoid)
			// Ref: https://www.mediawiki.org/wiki/Talk:Parsoid/Archive#Running_Parsoid_on_a_.22private.22_wiki_-_AccessDeniedError
			// Ref: https://www.mediawiki.org/wiki/Extension:VisualEditor#Linking_with_Parsoid_in_private_wikis
			if ( isset( $_SERVER['REMOTE_ADDR'] ) && isset( $_SERVER['SERVER_ADDR'] )
				&& $_SERVER['REMOTE_ADDR'] == $_SERVER['SERVER_ADDR'] )
			{
				$GLOBALS['wgGroupPermissions']['*']['read'] = true;
				$GLOBALS['wgGroupPermissions']['*']['edit'] = true;
			}

			// Enable by default for everybody
			$GLOBALS['wgDefaultUserOptions']['visualeditor-enable'] = 1;

			// Don't allow users to disable it
			$GLOBALS['wgHiddenPrefs'][] = 'visualeditor-enable';

			// OPTIONAL: Enable VisualEditor's experimental code features
			#$wgDefaultUserOptions['visualeditor-enable-experimental'] = 1;

			// URL to the Parsoid instance
			// MUST NOT end in a slash due to Parsoid bug
			// Use port 8142 if you use the Debian package
			$GLOBALS['wgVisualEditorParsoidURL'] = 'http://127.0.0.1:8000';

			// Interwiki prefix to pass to the Parsoid instance
			// Parsoid will be called as $url/$prefix/$pagename
			$GLOBALS['wgVisualEditorParsoidPrefix'] = $wikiId;

		}
	),


	/**
	 * Extensions for Elastic Search
	 **/
	'Elastica' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/Elastica.git',
		'branch' => 'REL1_25',
	),
	'CirrusSearch' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/CirrusSearch.git',
		'branch' => 'REL1_25',
		'afterFn' => function(){
			$GLOBALS['wgSearchType'] = 'CirrusSearch';

			global $wikiId, $m_htdocs;
			include "$m_htdocs/wikis/$wikiId/config/disableSearchUpdate.php";

			//$wgCirrusSearchServers = array( 'search01', 'search02' );
		},
	),

	'Echo' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/Echo.git',
		'branch' => 'REL1_25',
		'globals' => array(
			'wgEchoEmailFooterAddress' => $GLOBALS['wgPasswordSender'],
		),
	),

	'Thanks' => array(
		'git' => 'https://gerrit.wikimedia.org/r/mediawiki/extensions/Thanks.git',
		'branch' => 'REL1_25',
		'globals' => array(
			'wgThanksConfirmationRequired' => false,
		),
	),

);
