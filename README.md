# meza

[![Build Status](https://travis-ci.org/enterprisemediawiki/meza.svg?branch=master)](https://travis-ci.org/enterprisemediawiki/meza)

<img src="https://raw.githubusercontent.com/enterprisemediawiki/meza/master/manual/commands.gif">

Setup an enterprise MediaWiki server with **simple commands**. Put all components on a single monolithic server or split load balancer, web server, memcached, master and replica databases, Parsoid, Elasticsearch and backups all onto separate servers. Deploy to multiple environments. Run backups. Just use the `meza` command. `meza --help` for more info.

## Why meza?

Standard MediaWiki is very easy to install, but increasingly it's newer and better features are contained within extensions that are more complicated. Additionally, they may be particularly difficult to install on Enterprise Linux derivatives. This project aims to make these features (VisualEditor, CirrusSearch, etc) easy to install in a robust and well-tested way.

## Requirements

Install meza on CentOS 7 or RHEL 7 minimal install. Attempting to install it on a server with many other things already installed may not work properly due to conflicts.

## Install

Login to your server and run the following (should take 15-30 minutes depending on your connection):

```bash
curl -L getmeza.org > doit
sudo bash doit
sudo meza install monolith
```

### Installing on a VirtualBox machine

See more detailed steps on how to download CentoOS 7 and configure a Virtual Machine in our [setting up VirtualBox](manual/1.0-SettingUpVirtualBox.md) guide. If you already have a VM, just do this:

```bash
# This assumes you don't have networking on your VM, so you'll be
# manually typing these into VirtualBox rather than using SSH
curl -L getmeza.org > doit
sudo bash doit
sudo meza install dev-networking

# At this point you have SSH installed, so you can SSH into your VM
sudo meza install monolith
```

## See Also

* [Creating and importing wikis](manual/AddingWikis.md)
* [Accessing Elasticsearch plugins](manual/ElasticsearchPlugins.md)
* [Installing additional extensions](manual/installing-additional-extensions.md)
* [Directory structure overview](manual/DirectoryStructure.md)
* [Setup on Digital Ocean](manual/SetupDigitalOcean.md)

## Contributing

If you'd like to contribute to this project, please see [this guide on how to help](CONTRIBUTING.md).
