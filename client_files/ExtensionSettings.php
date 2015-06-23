<?php

// get config from: JSCMOD

// handle bad file names from:
// 'extensions/LabeledSectionTransclusion/lst.php' 
// 'extensions/LabeledSectionTransclusion/lsth.php' 
// "$IP/extensions/intersection/DynamicPageList.php"

// move to composer?: SemanticMeetingMinutes
// pretty sure this isn't needed with SMM: "$IP/extensions/Synopsize/Synopsize.php";


/**
 * Extensions being considered
 */
// 'ParserFunctionHelper' => array(
// 	'git' => 'https://github.com/enterprisemediawiki/ParserFunctionHelper.git',
// 	'branch' => 'master',
// ),

// not in wikimedia git, now in github/kghbln:
// https://github.com/kghbln/ImportUsers  -- may not work well with newer versions of MW
// consider taking into EMW
// 'ImportUsers' => array(
// 	'git' => 'https://git.wikimedia.org/git/mediawiki/extensions/ImportUsers.git',
// 	'branch' => 'master',
// 	'globals' => array(
// 		'wgShowExceptionDetails' => true,
// 	)
// ),

// In SVN, see https://www.mediawiki.org/wiki/Extension:Pipe_Escape
// Do we use this?
// 'PipeEscape' => array(
// 	'git' => 'https://git.wikimedia.org/git/mediawiki/extensions/PipeEscape.git',
// 	'branch' => 'master',
// ),



$egExtensionLoaderConfig += array(

	'ParserFunctions' => array(
		'git' => 'https://git.wikimedia.org/git/mediawiki/extensions/ParserFunctions.git',
		'branch' => 'REL1_25',
		'globals' => array(
			'wgPFEnableStringFunctions' => true,
		),
	),

	'StringFunctionsEscaped' => array(
		'git' => 'https://git.wikimedia.org/git/mediawiki/extensions/StringFunctionsEscaped.git',
		'branch' => 'REL1_25',
	),

	'ExternalData' => array(
		'git' => 'https://git.wikimedia.org/git/mediawiki/extensions/ExternalData.git',
		'branch' => 'REL1_25',
	),

	'Cite' => array(
		'git' => 'https://git.wikimedia.org/git/mediawiki/extensions/Cite.git',
		'branch' => 'REL1_25',
		'globals' => array(
			'wgCiteEnablePopups' => true,
		),
	),

	'HeaderFooter' => array(
		'git' => 'https://github.com/enterprisemediawiki/HeaderFooter.git',
		'branch' => 'master',
	),

	'WhoIsWatching' => array(
		'git' => 'https://git.wikimedia.org/git/mediawiki/extensions/WhoIsWatching.git',
		'branch' => 'REL1_25',
		'globals' => array(
			'wgPageShowWatchingUsers' => true,
		),
	),

	'CharInsert' => array(
		'git' => 'https://git.wikimedia.org/git/mediawiki/extensions/CharInsert.git',
		'branch' => 'REL1_25',
	),

	// 'SemanticForms' => array(
	// 	'git' => 'https://git.wikimedia.org/git/mediawiki/extensions/SemanticForms.git',
	// 	'branch' => 'REL1_25',
	// ),

	// 'SemanticInternalObjects' => array(
	// 	'git' => 'https://git.wikimedia.org/git/mediawiki/extensions/SemanticInternalObjects.git',
	// 	'branch' => 'REL1_25',
	// ),

	// 'SemanticCompoundQueries' => array(
	// 	'git' => 'https://git.wikimedia.org/git/mediawiki/extensions/SemanticCompoundQueries.git',
	// 	'branch' => 'REL1_25',
	// ),

	'Arrays' => array(
		'git' => 'https://git.wikimedia.org/git/mediawiki/extensions/Arrays.git',
		'branch' => 'REL1_25',
	),

	'TitleKey' => array(
		'git' => 'https://git.wikimedia.org/git/mediawiki/extensions/TitleKey.git',
		'branch' => 'REL1_25',
	),

	'TalkRight' => array(
		'git' => 'https://github.com/enterprisemediawiki/TalkRight.git',
		'branch' => 'master',
	),

	'AdminLinks' => array(
		'git' => 'https://git.wikimedia.org/git/mediawiki/extensions/AdminLinks.git',
		'branch' => 'REL1_25',
		'afterFn' => function() {
			$wgGroupPermissions['sysop']['adminlinks'] = true;
		}
	),

	'DismissableSiteNotice' => array(
		'git' => 'https://git.wikimedia.org/git/mediawiki/extensions/DismissableSiteNotice.git',
		'branch' => 'REL1_25',
	),

	'BatchUserRights' => array(
		'git' => 'https://git.wikimedia.org/git/mediawiki/extensions/BatchUserRights.git',
		'branch' => 'REL1_25',
	),


	'HeaderTabs' => array(
		'git' => 'https://git.wikimedia.org/git/mediawiki/extensions/HeaderTabs.git',
		'branch' => 'REL1_25',
		'globals' => array(
			'htEditTabLink' => false,
			'htRenderSingleTab' => true,
		)
	),

	'WikiEditor' => array(
		'git' => 'https://git.wikimedia.org/git/mediawiki/extensions/WikiEditor.git',
		'branch' => 'REL1_25',
		'afterFn' => function() {
			$wgDefaultUserOptions['usebetatoolbar'] = 1;
			$wgDefaultUserOptions['usebetatoolbar-cgd'] = 1;
			# displays publish button
			$wgDefaultUserOptions['wikieditor-publish'] = 1;
			# Displays the Preview and Changes tabs
			$wgDefaultUserOptions['wikieditor-preview'] = 1;
		}
	),

	'CopyWatchers' => array(
		'git' => 'https://github.com/jamesmontalvo3/MediaWiki-CopyWatchers.git',
		'branch' => 'master',
	),

	// consider replacing with SyntaxHighlight_Pygments
	// https://git.wikimedia.org/git/mediawiki/extensions/SyntaxHighlight_Pygments.git
	'SyntaxHighlight_GeSHi' => array(
		'git' => 'https://git.wikimedia.org/git/mediawiki/extensions/SyntaxHighlight_GeSHi.git',
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
		'git' => 'https://git.wikimedia.org/git/mediawiki/extensions/InputBox.git',
		'branch' => 'REL1_25',
	),

	'ReplaceText' => array(
		'git' => 'https://git.wikimedia.org/git/mediawiki/extensions/ReplaceText.git',
		'branch' => 'REL1_25',
	),

	'Interwiki' => array(
		'git' => 'https://git.wikimedia.org/git/mediawiki/extensions/Interwiki.git',
		'branch' => 'REL1_25',
		'afterFn' => function() {
			$wgGroupPermissions['sysop']['interwiki'] = true;
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

	'NumerAlpha' => array(
		'git' => 'https://github.com/jamesmontalvo3/NumerAlpha.git',
		'branch' => 'master',
	),

	'Variables' => array(
		'git' => 'https://git.wikimedia.org/git/mediawiki/extensions/Variables.git',
		'branch' => 'REL1_25',
	),

	'SummaryTimeline' => array(
		'git' => 'https://github.com/darenwelsh/SummaryTimeline.git',
		'branch' => 'master',
	),

	'YouTube' => array(
		'git' => 'https://git.wikimedia.org/git/mediawiki/extensions/YouTube.git',
		'branch' => 'REL1_25',
	),

	'ContributionScores' => array(
		'git' => 'https://git.wikimedia.org/git/mediawiki/extensions/ContributionScores.git',
		'branch' => 'REL1_25',
		'afterFn' => function() {
			$wgContribScoreIgnoreBots = true;          // Exclude Bots from the reporting - Can be omitted.
			$wgContribScoreIgnoreBlockedUsers = true;  // Exclude Blocked Users from the reporting - Can be omitted.
			$wgContribScoresUseRealName = true;        // Use real user names when available - Can be omitted. Only for MediaWiki 1.19 and later.
			$wgContribScoreDisableCache = false;       // Set to true to disable cache for parser function and inclusion of table.
			//Each array defines a report - 7,50 is "past 7 days" and "LIMIT 50" - Can be omitted.
			$wgContribScoreReports = array(
			    array(7,50),
			    array(30,50),
			    array(0,50));
		}
	),

);