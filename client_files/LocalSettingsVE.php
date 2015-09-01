
// ******* Begin info for VE *******

// Allow read and edit permission for requests from the server (e.g. Parsoid)
// Ref: https://www.mediawiki.org/wiki/Talk:Parsoid/Archive#Running_Parsoid_on_a_.22private.22_wiki_-_AccessDeniedError
// Ref: https://www.mediawiki.org/wiki/Extension:VisualEditor#Linking_with_Parsoid_in_private_wikis
if ( $_SERVER['REMOTE_ADDR'] == $_SERVER['SERVER_ADDR'] ) {
   $wgGroupPermissions['*']['read'] = true;
   $wgGroupPermissions['*']['edit'] = true;
}else{
   # Disable reading by anonymous users
   $wgGroupPermissions['*']['read'] = false;
   $wgWhitelistRead = array ("Special:Userlogin", "MediaWiki:Common.css",
   "MediaWiki:Common.js", "MediaWiki:Monobook.css", "MediaWiki:Monobook.js", "-");
   # Disable anonymous editing
   $wgGroupPermissions['*']['edit'] = false;
}

// Enable by default for everybody
$wgDefaultUserOptions['visualeditor-enable'] = 1;

// Don't allow users to disable it
$wgHiddenPrefs[] = 'visualeditor-enable';

// OPTIONAL: Enable VisualEditor's experimental code features
#$wgDefaultUserOptions['visualeditor-enable-experimental'] = 1;

// URL to the Parsoid instance
// MUST NOT end in a slash due to Parsoid bug
// Use port 8142 if you use the Debian package
$wgVisualEditorParsoidURL = 'http://127.0.0.1:8000';

// Interwiki prefix to pass to the Parsoid instance
// Parsoid will be called as $url/$prefix/$pagename
$wgVisualEditorParsoidPrefix = 'wiki';

// ******* End info for VE *******
