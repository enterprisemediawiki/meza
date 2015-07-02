

cd ~/sources

# Download, compile, and install node
wget https://nodejs.org/dist/v0.12.5/node-v0.12.5.tar.gz
tar zxvf node-v0.12.5.tar.gz
cd node-v0.12.5
./configure
make
make install

# Download and install parsoid
cd ..
git clone https://gerrit.wikimedia.org/r/p/mediawiki/services/parsoid
cd parsoid
npm install

--> npm WARN prefer global jshint@2.8.0 should be installed with -g

npm test #optional?

--> several warnings

# Configure parsoid for wiki use
cd api


*** use CLI to create localsettings.js with this content:

'use strict';

exports.setup = function(parsoidConfig) {
	// Set your own user-agent string
	// Otherwise, defaults to "Parsoid/<current-version-defined-in-package.json>"
	//parsoidConfig.userAgent = "My-User-Agent-String";

	// The URL of your MediaWiki API endpoint.
	parsoidConfig.setMwApi('MezaWiki', { uri: 'http://192.168.56.58/wiki/api.php' });
	// To specify a proxy (or proxy headers) specific to this prefix (which
	// overrides defaultAPIProxyURI) use:
	/*
	parsoidConfig.setMwApi('localhost', {
		uri: 'http://localhost/w/api.php',
		// set `proxy` to `null` to override and force no proxying.
		proxy: {
			uri: 'http://my.proxy:1234/',
			headers: { 'X-Forwarded-Proto': 'https' } // headers are optional
		}
	});
	*/

	// We pre-define wikipedias as 'enwiki', 'dewiki' etc. Similarly
	// for other projects: 'enwiktionary', 'enwikiquote', 'enwikibooks',
	// 'enwikivoyage' etc. (default true)
	//parsoidConfig.loadWMF = false;

	// A default proxy to connect to the API endpoints.
	// Default: undefined (no proxying).
	// Overridden by per-wiki proxy config in setMwApi.
	//parsoidConfig.defaultAPIProxyURI = 'http://proxy.example.org:8080';

	// Enable debug mode (prints extra debugging messages)
	//parsoidConfig.debug = true;

	// Use the PHP preprocessor to expand templates via the MW API (default true)
	//parsoidConfig.usePHPPreProcessor = false;

	// Use selective serialization (default false)
	parsoidConfig.useSelser = true;

	// Allow cross-domain requests to the API (default '*')
	// Sets Access-Control-Allow-Origin header
	// disable:
	//parsoidConfig.allowCORS = false;
	// restrict:
	//parsoidConfig.allowCORS = 'some.domain.org';

	// Set to true for using the default performance metrics reporting to statsd
	// If true, provide the statsd host/port values
	/*
	parsoidConfig.useDefaultPerformanceTimer = true;
	parsoidConfig.txstatsdHost = 'statsd.domain.org';
	parsoidConfig.txstatsdPort = 8125;
	*/

	// Alternatively, define performanceTimer as follows:
	/*
	parsoidConfig.performanceTimer = {
		timing: function(metricName, time) { }, // do-something-with-it
		count: function(metricName, value) { }, // do-something-with-it
	};
	*/

	// How often should we emit a heap sample? Time in ms.
	// This setting is only relevant if you have enabled
	// performance monitoring either via the default metrics
	// OR by defining your own performanceTimer properties
	//parsoidConfig.heapUsageSampleInterval = 5 * 60 * 1000;

	// Allow override of port/interface:
	//parsoidConfig.serverPort = 8000;
	//parsoidConfig.serverInterface = '127.0.0.1';

	// The URL of your LintBridge API endpoint
	//parsoidConfig.linterAPI = 'http://lintbridge.wmflabs.org/add';

	// Require SSL certificates to be valid (default true)
	// Set to false when using self-signed SSL certificates
	//parsoidConfig.strictSSL = false;

	// Use a different server for CSS style modules.
	// Set to true to use bits.wikimedia.org, or to a string with the URI.
	// Leaving it undefined (the default) will use the same URI as the MW API,
	// changing api.php for load.php.
	//parsoidConfig.modulesLoadURI = true;

	// Suppress some warnings from the Mediawiki API
	// (defaults to suppressing warnings which the Parsoid team knows to
	// be harmless)
	//parsoidConfig.suppressMwApiWarnings = /annoying warning|other warning/;
};

***

Read https://www.mediawiki.org/wiki/Extension:VisualEditor#Linking_with_Parsoid_in_private_wikis


# Start the server
cd .. (to parsoid dir)
node api/server.js

Note that you can't access the parsoid service via 192.168.56.58:8000 (at least by default), but you can use curl 127.0.0.1:8000 to verify it works

Need to replace or add after # Start the server with an automated way of starting the server (upon reboot)
https://www.mediawiki.org/wiki/Parsoid/Developer_Setup#Starting_the_Parsoid_service_automatically


# Install Extension:UniversalLanguageSelector

echo " " >> ~/sources/meza1/client_files/ExtensionSettings.php
echo "\$egExtensionLoaderConfig += array( " >> ~/sources/meza1/client_files/ExtensionSettings.php
echo "	'UniversalLanguageSelector' => array( " >> ~/sources/meza1/client_files/ExtensionSettings.php
echo "		'git' => 'https://gerrit.wikimedia.org/r/p/mediawiki/extensions/UniversalLanguageSelector.git', " >> ~/sources/meza1/client_files/ExtensionSettings.php
echo "		'branch' => 'REL1_25', " >> ~/sources/meza1/client_files/ExtensionSettings.php
echo "	), " >> ~/sources/meza1/client_files/ExtensionSettings.php
echo "	'VisualEditor' => array( " >> ~/sources/meza1/client_files/ExtensionSettings.php
echo "		'git' => 'https://gerrit.wikimedia.org/r/p/mediawiki/extensions/VisualEditor.git', " >> ~/sources/meza1/client_files/ExtensionSettings.php
echo "		'branch' => 'REL1_25', " >> ~/sources/meza1/client_files/ExtensionSettings.php
echo "	), " >> ~/sources/meza1/client_files/ExtensionSettings.php
echo "); " >> ~/sources/meza1/client_files/ExtensionSettings.php
echo "" >> ~/sources/meza1/client_files/ExtensionSettings.php

php /var/www/meza1/htdocs/wiki/extensions/ExtensionLoader/updateExtensions.php


cd /usr/var/meza1/htdocs/wiki/extensions/VisualEditor
git submodule update --init


Note documentation for multi-language support configuration: https://www.mediawiki.org/wiki/Extension:UniversalLanguageSelector

# Add to LocalSettings.php
some command ****

require_once "$IP/extensions/VisualEditor/VisualEditor.php";

// Enable by default for everybody
$wgDefaultUserOptions['visualeditor-enable'] = 1;

// Don't allow users to disable it
$wgHiddenPrefs[] = 'visualeditor-enable';

// OPTIONAL: Enable VisualEditor's experimental code features
#$wgDefaultUserOptions['visualeditor-enable-experimental'] = 1;

// URL to the Parsoid instance
// MUST NOT end in a slash due to Parsoid bug
// Use port 8142 if you use the Debian package
$wgVisualEditorParsoidURL = 'http://localhost:8000';

// Interwiki prefix to pass to the Parsoid instance
// Parsoid will be called as $url/$prefix/$pagename
$wgVisualEditorParsoidPrefix = 'MezaWiki';

Note: Other extensions which load plugins for VE (e.g. Math) should be loaded after VE for those plugins to work.




