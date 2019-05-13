Release Notes
=============

## Meza 31.4.0

Make importing from a live server simpler and more secure by not requiring sudo on the remote. Also use a more stable version of ImageMagick.

### Commits since 31.3.0

* 0d23cf7 Don't push
* 7ce4ddb Make script actually do release commit. Beware.
* 47f6518 Improvements to rel notes script order
* 7fe7b2e Make release script edit RELEASE-NOTES.md
* 02cb384 WIP: release notes script
* 7ea1f98 Use known user, not no user, when mysqldump user unspecified
* 84bc0a0 Install mysql client on backup servers for direct mysqldump
* 112317c Handle undefined backups_server_db_dump
* db6f805 Give undefined debug vars print vals
* cd79230 Make checks for wiki existence during backup go to right server
* 68ac393 Add tags for rsync-uploads and better debug
* 4d56386 Set permissions for /opt/conf-meza and /opt/conf-meza/public
* 6ecc855 Create role remote-dir-check to verify if remote uploads dir exists
* 527852f Get public config repo as meza-ansible, not root
* 51f5e34 Re-enable PEAR package; not used by default, but used by MS SQL
* af9eb52 Move vault pass file from meza-ansible home to /opt/conf-meza/vault
* bd6b103 Minor spelling mistakes
* 43691c4 Vagrantfile set mount_options: ["dmode=755,fmode=755"] Windows only
* 4127c78 Use base ImageMagick rather than Meza's own RPM
* 6ae982b Use 'remote_src'
* 186298a The SFTP server is in a different location on Debian

### Contributors

* 25	James Montalvo
* 3	Greg Rundlett

# How to upgrade

```bash
sudo meza update 31.4.0
sudo meza deploy <insert-your-environment-name>
```

## Meza 31.3.0

WatchAnalytics to 3.1.2 for diff in PendingReviews, improved on-page banners

### Commits since 31.2.5

* fc22af4 Bump to WatchAnalytics 3.1.2
* 70b4e2b Bump to WatchAnalytics 3.1.1
* ce403a5 Bump WatchAnalytics to 3.1.0

### Contributors

* 4	krisfield
* 1	James Montalvo

# How to upgrade

```bash
sudo meza update 31.3.0
sudo meza deploy <insert-your-environment-name>
```

## Meza 31.2.4

### Commits since 31.2.3

* 7b3a067 Add debug to troubleshoot backup issue (#1094)
* d5272fb Make backup a tag so that you can at least skip it
* 073a64f Make apache ServerAdmin email configurable (#1086)
* 48b3b13 Move prolific log files into sub-directories
* 619bea6 Use failed_when instead of ignore_errors (#1083)
* 368fd1b Use printf and quoting to preserve params
* 2028087 Add BEGIN rules to awk scripts

### Contributors

@jamesmontalvo3, @hexmode, @freephile

### Mediawiki.org pages updated

* Updated https://www.mediawiki.org/wiki/Meza/Directory_structure with log file locations

## Meza 31.2.3

Fixing bug in Extension:WatchAnalytics

### Commits since 31.2.2

* eea7891 bump WatchAnalytics to 2.0.1 (#1066)

### Contributors

Kris Field

### Mediawiki.org pages updated

None

## Meza 31.2.2

### Commits since previous release

* d544d8b Bumps WatchAnalytics to 2.0.0
* 1230747 Use GitHub mirrors for Gerrit repos
* 8be750b Merge pull request #1060 from enterprisemediawiki/ext-wa-0.1.0
* 9baa1d6 Change Extension:CopyWatchers from master to 0.10.0
* cde132c Change Extension:MezaExt from master to 0.1.0
* a92c786 Change Extension:ParserFunctionHelper from master to 1.0.0
* 2a75abc Change Extension:TalkRight from master to 2.0.0
* 87522d3 Change Extension:PageImporter from master to 0.1.0
* ffd07c7 Change Extension:SemanticMeetingMinutes from master to 1.0.0
* 00c178e Change Extension:NumerAlpha from master to 0.7.0
* 7313d78 Change Extension:MasonryMainPage from master to 0.3.0
* 296a47c Change Extension:ImagesLoaded from master to 0.1.0
* 3760316 Change Extension:Wiretap from master to 0.1.0
* 3026847 Change WatchAnalytics from master to 0.1.0

### Contributors

@jamesmontalvo3, @krisfield

### Mediawiki.org pages updated

* None

## Meza 31.2.1

### Commits since previous release

* 531b203 Reset +e prior to autodeployer deploys else second deploy fails (#1058)
* 324fa8b Update php.ini.j2 for `php_max_input_vars`
* 27730de Update defaults.yml for `php_max_input_vars`
* 60d50a5 Add fix for `php_max_input_vars` setting
* c64df3a Update robots.txt.j2

### Contributors

@bryandamon, @krisfield, @jamesmontalvo3

### Mediawiki.org pages updated

* https://www.mediawiki.org/wiki/Meza/Configuration_options added information about `php_max_input_vars`, which needs to be increased if using Page Forms with 1000s of inputs

## Meza 31.2.0

This release has two major changes. One, it bumps Semantic MediaWiki to v3.0.0, as well as updating related extensions. Two, it makes the 31.x branch as close as possible to what is required for running MW 1.32, including some tweaks to Parsoid and Elasticsearch settings, bumping PHP to 7.1, and upgrading Extension:Maps.

### Commits since 31.1.0

* dee80ba Bump PageForms to version that adds spreadsheet sorting (#1050)
* 532ffbc DataTransfer 1.0 doesn't have fixes for MW 1.31, use release branch instead (#1048)
* a8e3486 SMW rebuildData: better logging and attempt error handling
* 115cfa8 Use wfLoadExtension for SRF
* 8213181 Upgrade Pageforms to Version 4.4.1
* cfb4014 wfLoadExtension for SRF; bump Maps version slightly
* c85013f Cleanup parsoid version comments
* d432fb5 Update Extension:Maps to 6.0.1 (#1044)
* 98c0ff1 Upgrade Pageforms to Version 4.4.1
* be439a8 Bump PHP 7.0 to 7.1; include checks to remove old PHP versions
* 113c229 Set Parsoid strictAcceptCheck = false
* 1b27616 Upgrade CirrusSearch metastore before (re)indexing
* 69b5169 Bump SMW and SRF to 3.0.0. Bump SemanticCompoundQueries to 1.2.0 (#1040)
* e65045e Update pageforms to fix spreadsheet sorting (this didn't really fix it)

### Contributors

* @jamesmontalvo3
* @krisfield

### Mediawiki.org pages updated

* https://www.mediawiki.org/wiki/Meza added information on how to upgrade Meza, and bumped PHP version.

## Meza 31.1.1

Fix for change to Ansible's support of `enablerepo` option

### Commits since 31.1.0

* 7d1472e Update enablerepo functionality to work better with Ansible 2.7.0 (#1038)

### Contributors

@jamesmontalvo3

## Meza 31.1.0

Fix for PHP opcache, addition of Autodeployer, bump PageForms versions

### Commits since 31.0.0

* a9a8110 Update PageForms to get fix for tree input in SMW 3.0 (#1031)
* 3627d79 Update PageForms version to latest 30-Sep-2018 version (#1030)
* b21f178 Make do-deploy.sh use autodeployer Slack vars (#1029)
* fa39ab8 Fix Meza git commit hashes for autodeployer notifications (#1028)
* 5f3e9a7 Fix for config.php syntax error (#1027)
* 8c0242f Move config.sh|php into role to allow quick update for autodeployer (#1026)
* 38ccddf Add autodeployer (#1025)
* 31f6649 Make Meza control 10-opcache.ini to properly support modifying settings

### Contributors

@jamesmontalvo3, @krisfield

### Mediawiki.org pages updated

* Created https://www.mediawiki.org/wiki/Meza/Autodeployer
* Created https://www.mediawiki.org/wiki/Meza/Configuration_options and added Opcache options

## Meza 31.0.0

### Commits since 30.0.0

* 63bcee4 - Bump MediaWiki to 1.31.1 (#1022)
* c0d5107 - Bump SimpleSamlPhp from 1.15.4 to 1.16.1 (#1021)
* 4ef7580 - Bump SimpleSamlPhp from 1.15.1 to 1.15.4 (#1020)
* 102ba84 - Added PHP opcache optimization and configurability (#1019)
* 54d04b4 - Bump SemanticMediaWiki to 2.5.8 and SemanticResultFormats to 2.5.6 (#1018)
* a4c1f7d - Added Git fetch prune to MediaWiki core to fix `fatal: protocol error: bad pack header` (#1017)
* bd14949 - Fixed usage of `$wgVisualEditorAvailableNamespaces`
* f674e15 - Changed variable `$wgVisualEditorNamespaces` to `$wgVisualEditorAvailableNamespaces`
* 0725059 - Add Extension:TemplateData to Meza core extensions (#1014)
* ba1a953 - Show visual diff option on all diff pages (#1013)
* 06deff2 - Remove `legacy_load` from HeaderFooter (#1012)
* 0cf5b7f - Bump Extension:HeaderFooter to v3.0.0 (#1011)
* 8a61c74 - Move elasticsearch logs to `/opt/data-meza` instead of `/var/log` (#1008)
* 4f5b158 - Bump Approved Revs to properly handle usernames
* 0ea5846 - Add HSTS response header (#1002)
* 27229bb - Add python3 for Extension:SyntaxHighlight in MW1.31+ (#1004)
* 206720f - In `server-performance.sh` script, normalize load to num of CPUs; ref #866
* 6e50a44 - Use the official version of Approved Revs (#1001)
* 974f269 - Fix shared directory mode in Vagrant (#998)
* 59cfd30 - Allow adding core and additional Mediawiki skins (#997)
* 7dd9ff0 - Accept EULA when upgrading yum packages (#996)
* 596e0d7 - Fixed combination of MSSQL driver and autofs filesystem for `/home` (#995)
* 0a6da45 - Improved SSH defaults, allow not using default SSH config
* 453f299 - Added check if Parsoid svc exists prior to stopping it
* 03c08cf - Fixed when parsoid user directory needs to change, stop parsoid service first
* 9e8a501 - Make MediaWiki core ignore extension submodules
* 19a737c - Disable profiling extensions in php.ini due to incompatibility with PHP 7
* 9762440 - Specify MW 1.31.0 not REL1_31
* 74abcee - Fix several issues with 'meza update'
* 21945b4 - Add 'meza update' command
* 8d6146f - Remove require_once from some extensions, bump versions for PHP7/MW1.31
* 3ea4a9f - Several PHP7 fixes: TalkRight, xhprof, mongo, php5_module
* ecc9e42 - Changed to PHP 7.0
* 9d014dd - Started Meza 31.x branch; bump versions for MW 1.31, etc
* a8089b5 - PageForms to latest commit, greater than v4.3.1
* ba3b0fa - Added wiki-unification script used to generate ISS Wiki (#992)
* ea1c79f - Added Wiki ID redirects/aliases
* eaa9425 - Add method to skip overwrite on some wikis
* fc590c5 - Changed to CentOS 7.4 for Vagrant
* 0f2e70a - Fix for error in Travis CI due to temp dir permissions (#989)
* bc1e591 - Install MS SQL driver for PHP if install_ms_sql_driver=true

### Contributors

@jamesmontalvo3, @freephile, @darenwelsh, @djflux
