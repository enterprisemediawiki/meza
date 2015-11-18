CONTRIBUTING
============

There are several ways you can help contribute to meza.

## Report bugs

You may help us by reporting bugs and feature request via the issue tracker. Please remember to always provide information about your environment and any error messages you receive.

## Improve documentation

meza is in very early stages of development, and as such the documentation may become quickly out-of-date. If you see any issues with documentation please submit an issue and/or an update to the documentation.

## Provide patches

We have a long list of features to add and bugs to fix. We'd greatly appreciate any assistance making meza better.

## Test development builds

At any given time there are several new builds being considered for approval in our Pull Requests section. Please consider attempting to build these. The authors consider them ready for test if they are marked by the green "please review" label. If there are no pull requests marked "please review" we're always looking for more eyes on our master branch.

### Testing requirements

#### Minimal requirements

These tests should be performed on all changes

* Create page with wikitext editor
* Create page with VisualEditor
* Verify adding images to pages with VisualEditor
* Verify adding edit summary in VisualEditor
* Verify search works
* Verify ElasticSearch works by searching with a typo (e.g. search for "Test Paeg" when looking for "Test Page")
* Verify file uploads work
* Verify thumbnailing works (upload a larger image and verify small images are generated)
* Verify `create-wiki.sh` successfully creates a wiki

#### Desired testing

The following tests should be performed if time allows, or if a change is likely to affect any test.

* Verify `import-wikis.sh` imports multiple wikis
* Verify PDFHandler functioning (PDF images shown on PDF file pages)
* Verify image security: users unable to view images when not logged in
  * Test access to images when not logged into the wiki (use another browser)
    * Go to a file page with a logged in user and click the image and open in a new tab; verify you can view the image
    * Open that same image in another browser without being logged in; verify you can view the image
  * Add to `LocalSettings.php` to remove anonymous viewing:
    * `$wgGroupPermissions['*']['read'] = false;`
  * Test access to images from both browsers:
    * Verify logged in user can view image
    * Verify anonymous user CANNOT view image
  * Attempt to directly access image via URI like `http://example.com/wikis/<wiki-id>/images/a/a1/Image.png`
    * Verify logged in user CANNOT view image
    * Verify anonymous user CANNOT view image

#### Pre-release testing requirements

These tests should be performed prior to each release of meza, or any time  change is likely to affect any test.

* Repeat all tests for CentOS 6 32-bit
* Repeat all tests for CentOS 6 64-bit
* Repeat all tests for CentOS 7 (64-bit only)
* Create semantic properties in several pages, perform #ask query and verify results
* Perform tests on VirtualBox, Digital Ocean, AWS and Meza1-dev
