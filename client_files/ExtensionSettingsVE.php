
# Add 2 extensions required for VE
$egExtensionLoaderConfig += array(
	'UniversalLanguageSelector' => array(
		'git' => 'https://gerrit.wikimedia.org/r/p/mediawiki/extensions/UniversalLanguageSelector.git',
		'branch' => 'REL1_25',
	), " >> ~/sources/meza1/client_files/ExtensionSettings.php
	'VisualEditor' => array(
		'git' => 'https://gerrit.wikimedia.org/r/p/mediawiki/extensions/VisualEditor.git',
		'branch' => 'REL1_25',
	),
);

# End of VE additions
