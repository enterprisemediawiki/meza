app-ansible config directory
============================

Config files written by Ansible which need a place to live, and cannot be written to places like `/etc/parsoid` or `/opt/meza/htdocs/mediawiki`. The first file this was created for was Extensions.php, which is written by Ansible based upon MezaCoreExtensions.yml and MezaLocalExtensions.yml, but cannot be written to the same app config directory as PHP files rsynced from /opt/meza/config/local-public, because the rsync action would eliminate them.
