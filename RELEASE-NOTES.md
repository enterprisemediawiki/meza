Release Notes
=============

## Meza 31.13.0

Add new backups-cleanup method

### Commits since 31.12.0

* bba5624 Add backups cleanup that goes into each wiki dir for better cleanup options
* 805e3ed 31.12.0 release (#1279)

### Contributors

* 2	James Montalvo

### How to upgrade

```bash
sudo meza update 31.13.0
sudo meza deploy <insert-your-environment-name>
```

## Meza 31.12.0

Testing fixes, Add LDAP module, Bump MW to 1.31.12

### Commits since 31.11.0

* e05ea12 Bump base Vagrant RAM from 2GB to 4GB, else problems (#1278)
* 908ac75 Bump MW to 1.31.12 (#1277)
* 2380aa2 Enforce Composer 1.x version (#1275)
* 8b5c112 Added config variable use_ntp (#1271)
* 4160ae3 Bump MediaWiki to 1.31.7 (#1267)
* 65aa596 add ldap module (#1261)
* 591df68 Point tests to new Docker images built from this repo; only run build process on commits to master
* 8a22485 Remove secret.yml encryption per #1175
* 57e8469 Need --skip-conn-check on getmeza.sh within docker; temporarily skip other builds
* 11dc3e8 Make Dockerfiles pull FROM correct base image
* f01ae65 Add later test images
* 62886be Build test container 'base' on pushes to 'docker-build' branch
* b5ce5e3 GitHub Actions fail-fast-->false, to prevent one failure from cancelling all jobs
* 4cb414f Don't run tests twice for PRs
* 83d4bd6 Enable testing in GitHub Actions and GitLab CI

### Contributors

* 16	James Montalvo
* 1	Daren Welsh
* 1	Vincent Brooks

### How to upgrade

```bash
sudo meza update 31.12.0
sudo meza deploy <insert-your-environment-name>
```

## Meza 31.10.1

Fix PEAR channel

### Commits since 31.10.0

* e048a7b Ensure PEAR channel up-to-date

### Contributors

* 2	James Montalvo

### How to upgrade

```bash
sudo meza update 31.10.1
sudo meza deploy <insert-your-environment-name>
```

## Meza 31.10.0

Update PHP to 7.2, fix IUS repo, fix Python symlink

### Commits since 31.9.0

* bbe0009 Remove symlink creation for pip3; IUS appears to do that automatically now
* c50be32 Remove mcrypt extension no longer available after PHP 7.1
* 01c04bb Bump to PHP 7.2
* 10bc863 Fix typo (backslash)
* f701201 Add second IUS repo and GPG key
* 8e47150 Update URL to IUS RPM See https://github.com/iusrepo/announce/issues/18
* 44f2d2c Python 2/3 compatibility

### Contributors

* 6	James Montalvo
* 1	Andrew Foster
* 1	Daren Welsh
* 1	Greg Rundlett

### How to upgrade

```bash
sudo meza update 31.10.0
sudo meza deploy <insert-your-environment-name>
```

## Meza 31.9.0

Ansible 2.9 fix; Travis firewall fix

### Commits since 31.8.4

* 4d18daa yaml syntax fix
* 63716a8 fix more flag syntax
* fe78845 fix deprecated ansible syntax, ref c06fa04c7ddd0ea99c6e92b6f87ff89fd5be27a4
* 9dde2d8 Try Parsoid 0.10.0
* 121de9d Add --no-firewall deploy option
* 93b6087 Disable firewalld on travis tests
* 74a7697 Try manually restarting firewalld
* f9cc3a6 Travis saying Docker not running; perhaps start firewall after offline cmd
* 892fb1f With firewall-offline-cmd no --permanent option, prob because if offline none could be temp
* e1ced43 Possible solution to issue #1237 according to this forum:
* d1b17a9 Add a calendar interface to add and edit events using the Full…
* a555114 Add function to wait for Internet connection.

### Contributors

* 11	James Montalvo
* 4	Daren Welsh
* 1	Vincent Brooks
* 1	XP1

### How to upgrade

```bash
sudo meza update 31.9.0
sudo meza deploy <insert-your-environment-name>
```

## Meza 31.8.2

Multiple fixes in support of bad Composer issue, push-backups, etc

### Commits since 31.8.1

* 6722cdc Make meza-ansible:apache own deploy lock file, not root
* 16833fd Remove commented out non-ansible-module composer tasks
* deca0bb Use ansible composer module again
* c7c510e Mount local meza on docker tests controller containers
* 0a9ca06 Add error handling to update.php (show errors)
* dc7c184 WIP
* b1a140e Try envoking composer directly
* 2a49a3f Trying deleting composer.lock before composer operations
* 8b96dc1 Add --no-dev to MW composer commands
* ddb9fe2 Add refreshLinks script that handles memory leaks
* fb66fa3 Allow specifying rules for what to gzip in backups-cleanup
* 8093118 Make update.php write to a log
* ea7e7f6 Fix bad owner/group on /opt/data-meza
* 94c79c1 Fix bad variable
* 93d5a0d Improve logic for how to grab SQL file from backup
* 25b8013 Make pushed backups in form *push.sql and use them first; more debug

### Contributors

* 24	James Montalvo

### How to upgrade

```bash
sudo meza update 31.8.2
sudo meza deploy <insert-your-environment-name>
```

## Meza 31.8.1

Fix permissions for finicky servers; fix bad use of 'notify' tag on 'meza push-backup' command

### Commits since 31.8.0

* 597a49f Ensure MediaWiki and WikiBlender ownership after all operations
* 8f14b8f Recursively apply owner/perms to simplesaml and mediawiki
* 2803905 Specify /opt/simplesamlphp owner/group/mode
* 80177f4 push-backup: Fix bad use of 'notify' tag; Add servers to exclude

### Contributors

* 6	James Montalvo

### How to upgrade

```bash
sudo meza update 31.8.1
sudo meza deploy <insert-your-environment-name>
```

## Meza 31.8.0

Standardize secret config permissions; dev-networking fix

### Commits since 31.7.0

* 077e6bc Add lock_timeout to yum/package modules to fix Ansible 2.8 issue
* d6ddb60 Don't use 'meza' command for dev-networking
* 2ef8454 Secret directory 775 in getmeza.sh, too
* 8ba1353 file not directory
* ab1d9b1 Don't overwrite secrt files
* c64c41b Relax secret config _directory_ mode; ensure good ownership
* 968c675 Make meza-ansible own temp_vars.json
* dd245ae Sync secret perms

### Contributors

* 11	James Montalvo

### How to upgrade

```bash
sudo meza update 31.8.0
sudo meza deploy <insert-your-environment-name>
```

## Meza 31.7.0

Simplify push-backup settings and make cron configurable and with notification

### Commits since 31.6.0

* 8b109a7 Simplify push_backup settings
* 8a3c059 Fix missing endif
* 170596c Make push-backup cron configurable add notification

### Contributors

* James Montalvo

### How to upgrade

```bash
sudo meza update 31.7.0
sudo meza deploy <insert-your-environment-name>
```

## Meza 31.6.0

No longer require encryption of secret.yml; prefer variable-level encryption; fix permissions for rsync-push

### Commits since 31.5.0

* e70279c Don't print command for encrypt/decrypt (too much text)
* 63b86fa Add encrypt_string and decrypt_string meza commands
* 0c9555f Cleanup comments about encryption, remove secret.yml decryption from test case
* 3d88285 Remove auto-encrypting of secret.yml
* 419550a Add --no-perms to rsync-push

### Contributors

* 7	James Montalvo

### How to upgrade

```bash
sudo meza update 31.6.0
sudo meza deploy <insert-your-environment-name>
```

## Meza 31.5.0

Major deploy and autodeploy improvements; Push backups to remote server; Security and general improvements; bug fixes

### Commits since 31.4.0

#### Autodeploy on changes to secret config and use Ansible for autodeployer

Autodeployer has previously just tracked public config and the Meza application. Now it will check secret config, too. Additionally, autodeployer was rewritten in Ansible. Shell scripting got too cumbersome.

* 195cbea Fixes for autodeployer logic and misplaced variables
* 64896a5 Replace autodeployer scripts with Ansible
* 4dfb030 Belt and suspenders for ensuring deploy unlocks
* 006d5ed Reduce duplication in check-for-changes.sh
* 901f2b9 Make public config and Meza management by autodeployer optional
* 1dc9894 Use secret_config_repo to define secret config
* bce32d3 Autodeployer check for changes to secret config

#### Prevent simultaneous deploys and improve logging

Starting a deploy now creates a lock file. Other deploys cannot start until the locking deploy is complete. Additionally, all deploys automatically write to a log file and print to stdout. In the future this will be used to display deploy logs via the web interface.

* 60a680c Add wait() to capture return code
* e7b8ad3 Make sure deploy log directory exists
* 5009974 Always have ansible show colors
* a120ac3 Make meza_shell_exec use subprocess; optionally write to log file
* c5ef0e5 Add meza deploy-kill, deploy-log, deploy-tail functions
* 9438f7c Handle sigint; also better info in lock file
* a8f1aca Add 'meza deploy-(un)lock commands; Autodeployer use them to avoid conflicts
* dd60b91 Add meza subcommand to check if deploy underway
* 04e8ddb Prevent simultaneous deploys (#1157)

#### Make autodeployer configurable

In Meza 31.x prior to this release autodeployer, overwrite-deploys, and backups-cleanup had to be configured manually via crontab. 32.x has had the ability to configure these things in public/secret config for a while. This release pulls that functionality into 31.x.

* 220df48 Add autodeployer tag
* 87a4012 Make autodeployer, overwrite-deploy, and backups-cleanup configurable
* a5396d8 Fix location of backups-cleanup cron
* 28df042 Fix autodeployer crons

#### Push backups to an alternate server

Required if for security reasons dev/int servers cannot SSH into production to grab backups. Instead production can push backups directly to other servers. This was essentially possible before by making the other servers in the `backup-servers` group, but that (a) made it so production managed software configuration on the remote servers (as Meza does for all its server groups) and (b) it put file uploads in the `/opt/data-meza/backups` directory rather than in `/opt/data-meza/uploads`. So you'd have to do some symlink or have duplicated data. With pushed backups the production server (or whatever server is pushing) just needs to be setup so user `meza-ansible` can SSH into the server with a lesser-privileged account. The user must be in group `apache` and `meza-backups`.

* 6e54a86 Enable rsync push backups (#1166)
* 2784f81 Add option to recursively set perms on uploads dir; always run on overwrite

#### Security improvements

Steadily trying to reduce where `root` is required

* 36104ea Have meza-ansible do autodeployer git-fetch
* 2513a36 Set ownership of meza and config; fix role:init-controller-config

#### General improvements

* Vagrant improvements
  * bddb797 Unique VM names, /opt/meza owned by UID/GID 10000 in Vagrant
  * Unique VM names allows you to boot multiple Meza's on one host
  * UID/GID hack required to support using less `root`. Ref #1155
* Add `pip` and `pip3`
  * 3db517a Add pip for Python 2.7
  * 0155726 Add pip3 (31.x didn't have it yet)
  * 0f879f8 Make pip3 symlink for RHEL

#### Fix issues with creating Docker images for testing

Rebuilding Docker images for testing is not required often. It really only needs to be done when major changes are made or when a very long time has passed between generating images and new images will make test jobs run faster. Since a long time had passed, certain things had been added to Meza that unexpectedly caused issues with Docker builds.

* 36f965f Reorder AND statement since initial_wikis_dir_check undefined in docker build
* e919123 Don't use services during docker image building
* 0795348 More docker skip tasks

#### Bug fixes

* 46f7ac6 Make net adapter select statement break on newlines
* 40e4388 Don't recreate meza-ansible if user already exists (Revert #965)
* a621460 Remove yum:PackageKit to remove error
* 0502a41 Ansible 2.8 fixes (#1162) (`ansible_distribution_version` no longer present and `synchronize` module keeps getting harder to use)
* 6789e7d Ansible Git module fails with /tmp mounted with noexec; set TMPDIR as workaround
* 3854c6c Make sure to use TMPDIR when doing Ansible Git operations

### Contributors

* James Montalvo

### How to upgrade

```bash
sudo meza update 31.5.0
sudo meza deploy <insert-your-environment-name>
```

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

* James Montalvo
* Greg Rundlett

### How to upgrade

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

### How to upgrade

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
