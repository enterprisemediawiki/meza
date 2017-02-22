# meza v0.9

meza configures a CentOS/RedHat server with a complete enterprise MediaWiki installation.

## Server setup

meza requires a minimal installation of Enterprise Linux. Attempting to install it on a server with many other things already installed may not work properly due to conflicts. Depending on where you're installing meza you'll have different initial setup steps. The following environments have been tested.

* [Setup Digital Ocean](manual/SetupDigitalOcean.md)
* [Setup VirtualBox](manual/1.0-SettingUpVirtualBox.md)

## Running the setup script

Login to your server and run the following:

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
