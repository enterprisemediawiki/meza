<?php

global $wikiId;

enableSemantics( "Meza1.$wikiId" );

// SMW Settings Overrides:
$smwgQMaxSize = 5000;

$srfgFormats = array(
	'calendar',
	'timeline',
	'filtered',
	//'exhibit',
	'eventline',
	'tree',
	'oltree',
	'datatables',
	'ultree',
	'tagcloud',
	'sum',
	'pagewidget'
);

// allows adding semantic properties to Templates themselves
// (not just on pages via templates).
// ENABLE THIS AFTER ALL TEMPLATES HAVE BEEN CHECKED FOR PROPER FORM
// i.e. using <noinclude> and <includeonly> properly
// $smwgNamespacesWithSemanticLinks[NS_TEMPLATE] = true;
$smwgNamespacesWithSemanticLinks[NS_TALK] = true;

