CONTRIBUTING
============

There are several ways you can help contribute to meza.

## Report bugs

You may help us by reporting bugs and feature request via the issue tracker. Please remember to always provide information about your environment and any error messages you receive.

## Improve documentation

meza is in very early stages of development, and as such the documentation may become quickly out-of-date. If you see any issues with documentation please submit an issue and/or an update to the documentation.

## Provide patches

We have a long list of features to add and bugs to fix. We'd greatly appreciate any assistance making meza better.

## Run tests

Meza pulls together many complex systems. Testing is a big job. We always need help testing pull requests.

### Testing requirements

#### Minimal requirements

These tests should be performed on all changes

* Set `m_force_debug: true` in `/opt/conf-meza/public/public.yml`
* Create page with wikitext editor
* Create page with VisualEditor
* Verify adding images to pages with VisualEditor
* Verify adding edit summary in VisualEditor
* Verify search works
* Verify ElasticSearch works by searching with a typo (e.g. search for "Test Paeg" when looking for "Test Page")
* Verify file uploads work
* Verify thumbnailing works (upload a larger image and verify small images are generated)
* Verify `sudo meza create wiki` successfully creates a wiki

#### Desired testing

The following tests should be performed if time allows, or if a change is likely to affect any test.

* Verify `import-wikis.sh` imports multiple wikis
* Verify image security: users unable to view images when not logged in
  * Test access to images when not logged into the wiki (use another browser)
    * Go to a file page with a logged in user and click the image and open in a new tab; verify you can view the image
    * Open that same image in another browser without being logged in; verify you can view the image
  * Create `/opt/conf-meza/public/postLocalSettings.d/permissions.php` to remove anonymous viewing:
    * `$wgGroupPermissions['*']['read'] = false;`
    * After each change run `sudo meza deploy <env> --tags mediawiki --skip-tags latest,update.php,verify-wiki` to quickly pick up config changes
  * Test access to images from both browsers:
    * Verify logged in user can view image
    * Verify anonymous user CANNOT view image
  * Attempt to directly access image via URI like `http://example.com/wikis/<wiki-id>/images/a/a1/Image.png`
    * Verify logged in user CANNOT view image
    * Verify anonymous user CANNOT view image

#### Pre-release testing requirements

TBD
