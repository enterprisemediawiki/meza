This is an overview of the directory structure used by a meza server. This does not include every single file, but attempts to list out directories and files used by the meza application.

Info required: which files exist on which server types? Currently this is mostly focused on monolithic installations, where the controller and all applications (MariaDB, Elasticsearch, MediaWiki, etc) are on the same server.

## Glossary

There are several terms in this document which may be described in the [Glossary](Glossary.md).

## Major directories

The five major directories are:

1. `/opt/meza`: The meza application. Only modified when developing for or upgrading meza version
2. `/opt/conf-meza`: meza configuration. Modified by sysadmins when making configuration changes.
3. `/opt/data-meza`: storage of meza information. Modified anytime wiki users do anything on the site.
4. `/opt/.deploy-meza`: Files deployed by the meza application. Sysadmins don't need to touch this. Instead, modify `/opt/meza` or `/opt/conf-meza` and re-deploy.
5. `/opt/htdocs`: The webserver root. Deployed just like `/opt/.deploy-meza`.

## `/opt/meza`

Meza application directory. This should never change except if you upgrade meza (or you're doing development for the meza application itself). This only exists on the controller.

* `config`
  * `core`
    * `ansible.cfg`: Ansible config file. Ref: http://docs.ansible.com/ansible/intro_configuration.html
    * `defaults.yml`: base config vars, able to be overridden in /opt/conf-meza/public/vars.yml
    * `i18n`: mostly unused attempts to internationalize meza
    * `MezaCoreExtensions.yml`: extensions installed on all meza servers
    * `template`
      * `ifcfg-enp0s8`: CentOS7 VirtualBox Host-Only network interface template
  * `README.md`: FIXME #712: Flatten config/core/ to just config/
* `CONTRIBUTING.md`: Directions on how to contribute to meza
* `.eslintignore`: Config file for CodeClimate analysis
* `.eslintrc`: Config file for CodeClimate analysis
* `.github`
  * `ISSUE_TEMPLATE.md`: Template text for new GitHub issues
  * `PULL_REQUEST_TEMPLATE.md`: Template text for new GitHub pull requests
* `.gitignore`: Ref: https://git-scm.com/docs/gitignore
* `LICENSE`: license info for meza
* `manual`:
  * `commands.gif`: GIF for main README showing usage of meza command
  * `pigeon.txt`: ASCII art of pigeon declaring successful install; FIXME #676: reincorporate into deploy
  * `meza-cmd`:
    * (files used for help when using meza command, e.g. `meza --help`)
  * (various files explaining various aspects of meza)
* `README.md`: meza's main README
* `src`
  * `playbooks`:
    * (Ansible playbooks. Ref: http://docs.ansible.com/ansible/playbooks.html)
  * `roles`:
    * (Ansible roles. Ref: http://docs.ansible.com/ansible/playbooks_roles.html)
  * `scripts`
    * Run on hosts: `create-vm.sh`: Create a Vbox VM; remove when `vagrant up` mature? Or keep for RedHat
    * Setup dev VMs: `dev-networking.sh`: Setup host-only network on Vbox VM; Remove after Vagrant? Keep for RedHat setup?
    * Move to Ansible role [1]: `disk-space-usage.sh`: (needs to be within role on any server that needs disk space alerts. Currently requires MariaDB and Ansible present on logging servers)
    * Move to Ansible role [1]: `server-performance.sh`: (needs to be within role on any server that needs performance alerts. Currently requires MariaDB and Ansible present on logging servers)
    * Run on controller: `getmeza.sh`: (Used to install `meza` command)
    * Run on controller: `meza.py`: (Entry point for `meza` command)
    * Consolidate [2]: `shell-functions`:
      * `base.sh`:
      * `linux-user.sh`:
    * Consolidate [2]: `ssh-users`:
      * `setup-master-user.sh`:
      * `setup-minion-user.sh`:
      * `transfer-master-key.sh`:
    * `ssl-selftest.sh`: FIXME #714: Move to tests/integration/ and use in automated testing
    * `unifyUserTables.php`: FIXME #672: determine if still functional
* `tests`:
  * `deploys`: Scripts run on controllers which run several commands to test various functions
    * `backup-to-remote.controller.sh`:
    * `import-from-remote.controller.sh`:
    * `monolith-from-import.controller.sh`:
    * `monolith-from-scratch.controller.sh`:
    * `setup-alt-source-backup.yml`: Ansible playbook run on controller to setup a test case. creates a fake non-meza source to import from.
  * `docker`: Scripts run on a Docker host
    * `backup-to-remote.setup.sh`: generates 2 meza Docker containers
    * `import-from-alt-remote.setup.sh`: generates 2 meza Docker containers
    * `import-from-remote.setup.sh`: generates 2 meza Docker containers
    * `init-container.sh`: generates a generic container
    * `init-controller.sh`: uses init-container to generate a controller container
    * `init-minion.sh`: uses init-container to generate a minion container
    * `run-tests.sh`: Entrypoint script to setup which tests to run. first argument for this script is which test type to run.
  * `integration`:
    * `image-check.sh`: finds image URL via JS API, the checks is present on server
    * `server-check.sh`: several basic tests to verify a meza installation is functioning
    * `wiki-check.sh`: checks wiki API, Parsoid, Elasticsearch for a wiki
  * `travis`:
    * `git-setup.sh`: shim to handle git checkout funnies in Travis
* `.travis.yml`: Config file for Travis CI automated testing
* `Vagrantfile`: Create VMs with Vagrant. Ref: https://www.vagrantup.com/docs/vagrantfile/

[1] These items need to be moved into Ansible roles for maintenance and multi-server deployment. FIXME #625 #662 #735

[2] These are shell scripts used to create users. FIXME #713: Consolidate


## `/opt/conf-meza`

Location of configuration setup for meza. This is split into `secret` and `public` config. Secret config is intended for sensitive info like passwords. It also houses your `hosts` file which declares which servers have which components installed (e.g. Parsoid is installed on `192.168.56.80`). The `hosts` file may or may not be considered sensitive, but it resides in `secret` nonetheless. Some non-sensitive items may be more convenient to put in `secret`. These include things like `enable_wiki_emails`, which you may only want set to `true` on your production setup and no others. Since the `hosts` file resides in `secret` those environment-specific settings may be better to keep in `secret`.

Additionally, the user `meza-ansible` is used by meza to perform most actions. Some other actions are performed by the `alt-meza-ansible` user. However, we don't create these users in `/home` due to possible conflicts with other user systems. Ref #727.

* `public`:
  * `MezaLocalExtensions.yml`: Use to define extra extensions for your meza installation
  * `vars.yml`: MAIN CONFIGURATION VARIABLES FILE!
  * `postLocalSettings.d/`:
    * (Any .php files here will be loaded at the end of LocalSettings.php)
  * `preLocalSettings.d/`:
    * (Any .php files here will be loaded at the beginning of LocalSettings.php)
  * `wikis`:
    * `demo`: this "demo" is known as the wiki ID
      * `favicon.ico`: favicon
      * `logo.png`: logo
      * `postLocalSettings.d`:
        * (`.php` files here loaded at end of LocalSettings.php for this wiki only)
      * `preLocalSettings.d`:
        * `base.php`:
        * (`.php` files here loaded at beginning of LocalSettings.php for this wiki only)
    * (more wikis with same format as above)
* `secret`:
  * `monolith`:
    * `group_vars`:
      * `all.yml`: This is the main secret config file. It's location is due to Ansible best-practices of handling config files relative to location of hosts file (see below). Encrypted by vault password.
        * Ref http://docs.ansible.com/ansible/playbooks_best_practices.html#directory-layout
        * Ref #624 regarding moving group_vars/all.yml to secret.yml
    * `hosts`: AKA "Inventory file", listing server roles. See [Glossary](Glossary.md) for more info
    * `ssl`:
      * `meza.crt`: SSL certificate for this environment. Encrypted by vault password
      * `meza.key`: Private key for this environment. Encrypted by vault password
  * (more enviroments if you so choose)
* `users`
  * `meza-ansible`:
    * `.ssh`:
      * `id_rsa`: secret key file on controller only. KEEP SAFE!
      * `id_rsa.pub`: public key file. This needs to be put on any minion servers.
    * `.vault-pass-monolith.txt`: vault password file for monolith environment. See /opt/conf-meza above. On controller only
    * `.vault-pass-<env>.txt`: (vault password file for other environments)
  * `alt-meza-ansible`: alternate user for some operations to avoid conflicts

## `/opt/data-meza`

Data storage for meza. This is basically any information generated by using meza, including MariaDB (MySQL) database info, files uploaded by users, logs from meza commands (logs from Apache, HAProxy, system logs, etc are kept in their standard CentOS/RHEL locations), temp files, and backups from running `meza backup` command.

* `backups`: backups directory populated from running `meza backup <environment>`
  * `monolith`: backups for the "monolith" environment
    * `demo`:
      * `20170523123216_wiki.sql`: database backup from specified timestamp
      * `uploads/`: backup of uploads directory
  * `production`: backups for the "production" environment
    * (wikis in production)
* `elasticsearch`: files associated with Elasticsearch data
* `logs`:
  * `jobs_20170525_cron.log`: log from automated job runner
  * `parsoid-restart.log`: log from nightly parsoid restarts
  * `search-index.demo.1495583788.log`: log from this wiki's search index rebuilding
  * `smw-rebuilddata-out.demo.1495583793.log`: log from this wiki's SMW rebuildData.php
* `mariadb`: many files and directories associated with MariaDB data
  * `mysql-bin.000001`: FIXME #613: mysql-bin files are not cleaned up by meza currently
  * `mysql-bin.000002`:
  * `mysql-bin.......`:
  * `mysql-bin.00000N`:
* `tmp`: temp files which can be deleted. FIXME #497: need to keep this directory clean
* `uploads`:
  * `demo`: location where Demo Wiki's uploads/images are kept
  * (more wikis uploads/ directories)
* `uploads-gluster`: used instead of `uploads` if multiple app-servers used. File system distributed between app-servers.

## `/opt/.deploy-meza`

This directory is a hidden directory (e.g. starts with a period) because it really shouldn't be modified directly. When the `meza deploy` command is run this directory is set based upon the config set in `/opt/conf-meza`.

* `config.php`: PHP config variable file written based off defaults, secret and public config
* `config.sh`: Bash config variable file written based off defaults, secret and public config
* `Extensions.php`: Extensions to load, written based off core and local extensions
* `logging.sh`: Config variables specific to logging. FIXME #715: merge into config.sh
* `elastic-build-index.sh`: Rebuild Elasticsearch index for a wiki. Deployed by `role:mediawiki`
* `elastic-rebuild-all.sh`: Wrapper for `elastic-build-index.sh`. Deployed by `role:mediawiki`
* `smw-rebuild-all.sh`: Rebuild SMW data for all wikis. Deployed by `role:mediawiki`
* `public`: A copy of /opt/conf-meza/public, but present on all app-servers, as opposed to `/opt/conf-meza` which is only present on the controller
  * `MezaLocalExtensions.yml`: present but not used within .deploy-meza (controller only)
  * `postLocalSettings.d`: gives app servers access to these files
  * `preLocalSettings.d`: gives app servers acces to these files
  * `vars.yml`: present but not used within .deploy-meza (controller only)
  * `wikis`:
    * `demo`: gives app servers access to these logos and wiki specific PHP
* `runAllJobs.php`: Used in cron jobs to run jobs


## `/opt/htdocs`

This directory is similar to `/opt/.deploy-meza` in that it is a deployed directory: It is put in place on app servers by the meza application. In fact, it was considered to be placed at `/opt/.deploy-meza/htdocs` but due to its larger significance as the web root it seemed like it should have its own directory.

* `index.php`: entrypoint for landing page
* `mediawiki`: mediawiki application. many items not shown below
  * `extensions/`: where extensions are installed (by the meza application; sysadmins do not need to touch this)
  * `LocalSettings.php`: Settings file generated based on your config
  * `LocalSettings.php.17294.2017-05-22@18:59:46~`: FIXME #710: backups of LocalSettings.php not required
  * `LocalSettings.php.22591.2017-05-23@00:36:42~`: (see above)
  * `LocalSettings.php.31311.2017-05-23@19:03:29~`: (see above)
* `ServerPerformance`: logging and performance graphs
  * `css`:
    * `nv.d3.css`:
  * `index.php`: server performance
  * `js`:
    * `d3.js`:
    * `jquery-3.1.0.min.js`:
    * `nv.d3.js`:
    * `server-performance.nvd3.js`:
  * `mod_status.php`: Apache's mod_status page
  * `space.php`: disk space usage
* `WikiBlender`: landing page repo. Perhaps should be rolled into meza
* `wikis`:
  * `demo`: directory that symlinks to deployed config, to make logo/favicon web accessible
    * `config`: symlink to `/opt/.deploy-meza/public/wikis/demo` (FIXME #709: Security implications)
  * (more wikis)
