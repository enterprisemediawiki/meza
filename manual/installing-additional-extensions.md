Installing additional extensions
================================

meza comes pre-built with many extensions, but if you need additional extensions you can add them to any configuration file. The recommended method for adding extensions to all wikis is to use your "postLocalSettings_allWikis.php" file in `/opt/meza/config/local`. This file may not already exist, but if you add it meza will automatically start using it.

An example file is located at `/opt/meza/config/template/more-extensions.php`. This shows a method to load extensions for all wikis or just for select wikis.

After you've moved this file into `postLocalSettings_allWikis.php`, or included it from `postLocalSettings_allWikis.php`, you need to perform the installation. To do that run:

```
sudo WIKI=<wiki-id> php /opt/meza/htdocs/mediawiki/extensions/ExtensionLoader/updateExtensions.php
```

Replace `<wiki-id>` with any wiki ID. If the extensions you are installing require database updates (e.g. if their install instructions tell you to run `update.php`) then you will need to run `update.php` for **all wikis**. To do that, run the following:

```
sudo WIKI=<wiki-id> php /opt/meza/htdocs/mediawiki/maintenance/update.php
```

Do the command above for all wiki IDs.
