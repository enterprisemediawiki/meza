<?php
/**
 *  Additional extensions for meza
 *
 *  While you can choose to load additional extensions into meza however you'd
 *  like, this is one method. Move this file into `/opt/meza/config/local` and
 *  rename it to `postLocalSettings_allWikis.php`. If you already have
 *  `postLocalSettings_allWikis.php` and would prefer not to add all this
 *  content to it, pick another name and `require_once` the file.
 *
 *  In the file below five other extensions are loaded, one by default and four
 *  only if certain variables are set to `true`. Enabling these four extensions
 *  can be done in each wiki's `preLocalSettings.php` file (not the all-wiki
 *  `preLocalSettings.php`)
 *
 **/


#
# Extension:IMSQuery
#
require_once $egExtensionLoader->registerLegacyExtension(
	"IMSQuery",
	"https://github.com/jamesmontalvo3/IMSQuery.git",
	"master"
);


if ( isset( $mezaLoadSummaryTimeline ) && $mezaLoadSummaryTimeline ) {

	#
	# Extension:SummaryTimeline
	#
	require_once $egExtensionLoader->registerLegacyExtension(
		"SummaryTimeline",
		"https://github.com/darenwelsh/SummaryTimeline.git",
		"tags/v0.2.0"
	);

}


if ( isset( $mezaLoadTOPO ) && $mezaLoadTOPO ) {

	#
	# Extension:HideSubPage
	#
	require_once $egExtensionLoader->registerLegacyExtension(
		"HideSubPage",
		"https://github.com/emanspeaks/HideSubPage.git",
		"master"
	);

	#
	# Extension:CrossReference
	#
	require_once $egExtensionLoader->registerLegacyExtension(
		"CrossReference",
		"https://github.com/jamesmontalvo3/CrossReference.git",
		"master"
	);

	#
	# Extension:TreeAndMenu
	#
	require_once $egExtensionLoader->registerLegacyExtension(
		"TreeAndMenu",
		"https://github.com/jamesmontalvo3/TreeAndMenu.git",
		"master"
	);


	$wgHooks['BeforePageDisplay'][] = 'wfAddSidebarTree';
	function wfAddSidebarTree( $out, $skin ) {
		$title = Title::newFromText( 'SidebarTree', NS_MEDIAWIKI );
		$article = new Article( $title );
		$html = $out->parse( $article->getContent() );
		$out->addHTML( "<div id=\"wikitext-sidebar\">$html</div>" );
		return true;
	}

}
