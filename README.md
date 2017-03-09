# meza

[![Build Status](https://travis-ci.org/enterprisemediawiki/meza.svg?branch=master)](https://travis-ci.org/enterprisemediawiki/meza)

<img src="https://raw.githubusercontent.com/enterprisemediawiki/meza/master/manual/commands.gif">

Setup an enterprise MediaWiki server with simple commands. Put all components on a single monolithic server or split load balancer, web server, memcached, master and replica databases, Parsoid, Elasticsearch and backups all onto separate servers. Deploy to multiple environments. Run backups. Just use the `meza` command. `meza --help` for more info.

## Server setup

meza requires a minimal installation of Enterprise Linux. Attempting to install it on a server with many other things already installed may not work properly due to conflicts. Depending on where you're installing meza you'll have different initial setup steps. The following environments have been tested.

* [Setup Digital Ocean](manual/SetupDigitalOcean.md)
* [Setup VirtualBox](manual/1.0-SettingUpVirtualBox.md)

## Running the setup script

Login to your server and run the following (should take 20-45 minutes):

```bash
curl -L getmeza.org > doit
sudo bash doit
sudo meza install monolith
```

## See Also

* [Creating and importing wikis](manual/AddingWikis.md)
* [Accessing Elasticsearch plugins](manual/ElasticsearchPlugins.md)
* [Installing additional extensions](manual/installing-additional-extensions.md)
* [Directory structure overview](manual/DirectoryStructure.md)

## Contributing

If you'd like to contribute to this project, please see [this guide on how to help](CONTRIBUTING.md).
