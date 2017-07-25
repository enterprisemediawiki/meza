Installing additional extensions
================================

Meza comes pre-built with many extensions, but additional extensions can be added to an installation. To do so:

1. Add the extensions to the `MezaLocalExtensions.yml` configuration file
2. Run `sudo meza deploy <env>` where "env" is your environment name (probably "monolith")

## Adding extensions

Extensions can be added to `/opt/conf-meza/public/MezaLocalExtensions.yml` in the following ways. If adding your first extension, please make sure the part that says `list: []` (an empty list) is changed to `list:`. Then add extensions as follows.

### Standard extension configuration
```yaml
  - name: CommentStreams
    repo: https://gerrit.wikimedia.org/r/mediawiki/extensions/CommentStreams.git
    version: master
    config: |
      $wgCommentStreamsEnableTalk = true;
```

### Legacy extensions
If the extension you're trying to install has documentation on mediawiki.org saying to put a `require_once` statement into `LocalSettings.php`, then extension uses the legacy loading method. To add it, include `legacy_load: True` as follows:

```yaml
  - name: UserJourney
    repo: https://github.com/darenwelsh/UserJourney
    version: master
    legacy_load: True
    config: |
      $fakeVarJustForTesting = false;
```

### Composer installation
If the extension says to use Composer to install it, use the following format:
```yaml
  - name: Semantic Breadcrumb Links
    composer: mediawiki/semantic-breadcrumb-links
    version: "~1.3"
    config: |
      $egSBLTryToFindClosestDescendant = true;
```

### Limiting to specific wikis
Additionally, `MezaLocalExtensions.yml` is able to limit the inclusion of extensions to specific wikis as follows. This would limit Extension:CommentStreams to only be loaded by the "robo" and "cronus" wikis.
```yaml
  - name: CommentStreams
    repo: https://gerrit.wikimedia.org/r/mediawiki/extensions/CommentStreams.git
    version: master
    config: |
      $wgCommentStreamsEnableTalk = true;
    wikis:
      - robo
      - cronus
```

### Extensions that require a separate Composer install step

Some extensions, like [Elastica](https://www.mediawiki.org/wiki/Extension:Elastica), say that in addition to downloading the code you must also `cd` into the `Elastica` directory and then run `composer install`. To make Meza handle this for you, add `composer_merge: True` to your extension configuration:

```yaml
  - name: Elastica
    repo: https://gerrit.wikimedia.org/r/mediawiki/extensions/Elastica.git
    version: "{{ mediawiki_default_branch }}"
    composer_merge: True
```

Note: Elastica is installed on Meza by default, so this is for example only.

### Extensions that require a Git submodule step

Some extensions, perhaps currently only [Visual Editor](https://www.mediawiki.org/wiki/Extension:VisualEditor), say that in addition to downloading the code you must also `cd` into the `VisualEditor` directory then run `git submodule update --init`. To make Meza handle this for you, add `git_submodules: True` to the extension's configuration:

```yaml
  - name: VisualEditor
    repo: https://gerrit.wikimedia.org/r/p/mediawiki/extensions/VisualEditor.git
    version: "{{ mediawiki_default_branch }}"
    git_submodules: True
```

Note: Visual Editor is installed on Meza by default, so this is for example only.

## Example MezaLocalConfig.yml

```yaml
---
list:
  # A legacy loaded extension
  - name: UserJourney
    repo: https://github.com/darenwelsh/UserJourney
    version: master
    legacy_load: True
    config: |
      $fakeVarJustForTesting = false;

  # A modern loaded extension, limited just to the demo wiki
  - name: CommentStreams
    repo: https://gerrit.wikimedia.org/r/mediawiki/extensions/CommentStreams.git
    version: master
    config: |
      $wgCommentStreamsEnableTalk = true;
    wikis:
      - demo

  # A Composer loaded extension (these cannot be limited to specific wikis)
  - name: Semantic Breadcrumb Links
    composer: mediawiki/semantic-breadcrumb-links
    version: "~1.3"
    config: |
      $egSBLTryToFindClosestDescendant = true;
```

## Adding extensions to Meza core

There is a file very similar to `MezaLocalExtensions.yml` located at `config/core/MezaCoreExtensions.yml`. This is the list of extensions installed as part of every Meza installation. If you want to request that an extension be added to Meza core you'll need to edit this file in the same way that you edit `MezaLocalExtensions.yml`, and then submit a pull request to `enterprisemediawiki/meza`. The only difference in functionality between the core and local files is that `MezaCoreExtensions.yml` does not support limiting extensions to specific wikis.
