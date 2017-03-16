# meza

[![Build Status](https://travis-ci.org/enterprisemediawiki/meza.svg?branch=master)](https://travis-ci.org/enterprisemediawiki/meza)
[![Code Climate](https://codeclimate.com/github/enterprisemediawiki/meza/badges/gpa.svg)](https://codeclimate.com/github/enterprisemediawiki/meza)

<img src="https://raw.githubusercontent.com/enterprisemediawiki/meza/master/manual/commands.gif">

Setup an enterprise MediaWiki server with **simple commands**. Put all components on a single monolithic server or split them out over many. Run a solitary master database or have replicas. Deploy to multiple environments. Run backups. Do it all using the `meza` command. Run `meza --help` for more info.

## Table of contents

  - [Why meza?](#why-meza)
  - [Requirements](#requirements)
  - [Install](#install)
  - [What is installed?](#what-is-installed)
    - [Software and versions](#software-and-versions)
    - [MediaWiki extensions](#mediawiki-extensions)
  - [See also](#see-also)
  - [Contributing](#contributing)

## Why meza?

Standard MediaWiki is easy to install, but increasingly its newer and better features are contained within extensions that are more complicated. Additionally, they may be particularly difficult to install on Enterprise Linux derivatives. This project aims to make these features (VisualEditor, CirrusSearch, etc) easy to *install, backup, reconfigure, and maintain* in a robust and well-tested way.

## Requirements

1. CentOS 7 or RHEL 7 (for now)
2. Minimal install: Attempting to install it on a server with many other things already installed may not work properly due to conflicts.

## Install

Login to your server and run the following (should take 15-30 minutes depending on your connection):

```bash
curl -L getmeza.org > doit
sudo bash doit
sudo meza deploy monolith
```

Running VirtualBox and need to get your virtual machine configured? See our
[setting up VirtualBox](manual/1.0-SettingUpVirtualBox.md) guide.

## What is installed?

Everything can be installed on a single server (a monolith, `meza install monolith`) or can be configured to install different components on different servers. For example, you may have the following setup:

* 2 load balancers
* 3 app servers (NOTE: this is still in development, and app servers do not yet have the ability to share uploads (a pretty major limitation))
* 3 memcached servers
* 1 database master
* 3 database replicas
* 2 Parsoid servers
* 3 elasticsearch nodes
* 2 backup servers

### Software and versions
* MediaWiki 1.27.1
* PHP 5.6
* Apache 2.4
* MariaDB 5.5, configurable optionally with multiple replica servers
* Load Balancer: HAProxy 1.5
* Memcached 1.4
* Elasticsearch 1.6
* Node.JS 6.9.4

### MediaWiki extensions
This is not necessarily an exhaustive list

* [Semantic MediaWiki](https://www.semantic-mediawiki.org) v2.4.6
* [Semantic Compound Queries](https://www.mediawiki.org/wiki/Extension:Semantic_Compound_Queries)
* [Semantic Internal Objects](https://www.mediawiki.org/wiki/Extension:Semantic_Internal_Objects)
* [Semantic Maps](https://github.com/SemanticMediaWiki/SemanticMaps/blob/master/README.md#semantic-maps)
* [Semantic Meeting Minutes](http://github.com/enterprisemediawiki/SemanticMeetingMinutes)
* [Semantic Result Formats](https://www.semantic-mediawiki.org/wiki/Semantic_Result_Formats)
* [Admin Links](https://www.mediawiki.org/wiki/Extension:Admin_Links)
* [BatchUserRights](https://www.mediawiki.org/wiki/Extension:BatchUserRights)
* [Contribution Scores](https://www.mediawiki.org/wiki/Extension:Contribution_Scores)
* [Copy Watchers](http://www.mediawiki.org/wiki/Extension:CopyWatchers)
* [Data Transfer](https://www.mediawiki.org/wiki/Extension:Data_Transfer)
* [Echo](https://www.mediawiki.org/wiki/Extension:Echo)
* [Interwiki](https://www.mediawiki.org/wiki/Extension:Interwiki)
* [Replace Text](https://www.mediawiki.org/wiki/Extension:Replace_Text)
* [Semantic Forms](https://www.mediawiki.org/wiki/Extension:Semantic_Forms)
* [WatchAnalytics](https://www.mediawiki.org/wiki/Extension:WatchAnalytics)
* [WhoIsWatching](https://www.mediawiki.org/wiki/Extension:WhoIsWatching)
* [Wiretap](https://www.mediawiki.org/wiki/Extension:Wiretap)
* [Arrays](https://www.mediawiki.org/wiki/Extension:Arrays)
* [CharInsert](https://www.mediawiki.org/wiki/Extension:CharInsert)
* [Cite](https://www.mediawiki.org/wiki/Extension:Cite)
* [External Data](https://www.mediawiki.org/wiki/Extension:External_Data)
* [InputBox](https://www.mediawiki.org/wiki/Extension:InputBox)
* [LabeledSectionTransclusion](https://www.mediawiki.org/wiki/Extension:Labeled_Section_Transclusion)
* [Maps](https://github.com/JeroenDeDauw/Maps/blob/master/README.md#maps)
* [MasonryMainPage](http://github.com/enterprisemediawiki/MasonryMainPage)
* [Math](https://www.mediawiki.org/wiki/Extension:Math)
* [NumerAlpha](https://www.mediawiki.org/wiki/Extension:NumerAlpha)
* [ParserFunctions](https://www.mediawiki.org/wiki/Extension:ParserFunctions)
* [Pipe Escape](https://www.mediawiki.org/wiki/Extension:Pipe_Escape)
* [SubPageList](https://github.com/JeroenDeDauw/SubPageList/blob/master/README.md)
* [SyntaxHighlight](https://www.mediawiki.org/wiki/Extension:SyntaxHighlight_GeSHi)
* [Variables](https://www.mediawiki.org/wiki/Extension:Variables)
* [YouTube](https://www.mediawiki.org/wiki/Extension:YouTube)
* [Approved Revs](https://www.mediawiki.org/wiki/Extension:Approved_Revs)
* [CirrusSearch](https://www.mediawiki.org/wiki/Extension:CirrusSearch)
* [CollapsibleVector](https://www.mediawiki.org/wiki/Extension:CollapsibleVector)
* [DismissableSiteNotice](https://www.mediawiki.org/wiki/Extension:DismissableSiteNotice)
* [Elastica](https://www.mediawiki.org/wiki/Extension:Elastica)
* [HeaderFooter](http://mediawiki.org/wiki/Extension:HeaderFooter)
* [Parser Function Helper](http://github.com/jamesmontalvo3/ParserFunctionHelper.git)
* [ParserHooks](https://github.com/JeroenDeDauw/ParserHooks)
* [TalkRight](http://www.mediawiki.org/wiki/Extension:Talkright)
* [Thanks](https://www.mediawiki.org/wiki/Extension:Thanks)
* [UniversalLanguageSelector](https://www.mediawiki.org/wiki/Extension:UniversalLanguageSelector)
* [Upload Wizard](https://www.mediawiki.org/wiki/Extension:UploadWizard)
* [Validator](https://github.com/JeroenDeDauw/Validator)
* [VisualEditor](https://www.mediawiki.org/wiki/Extension:VisualEditor)
* [WikiEditor](https://www.mediawiki.org/wiki/Extension:WikiEditor)

## See also

* [Creating and importing wikis](manual/AddingWikis.md)
* [Accessing Elasticsearch plugins](manual/ElasticsearchPlugins.md)
* [Installing additional extensions](manual/installing-additional-extensions.md)
* [Directory structure overview](manual/DirectoryStructure.md)
* [Setup on Digital Ocean](manual/SetupDigitalOcean.md)

## Contributing

If you'd like to contribute to this project, please see [this guide on how to help](CONTRIBUTING.md). 
