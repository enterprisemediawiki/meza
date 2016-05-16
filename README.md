# meza v0.9

meza configures a CentOS/RedHat server with a complete enterprise MediaWiki installation.

## Server setup

meza requires a minimal installation of Enterprise Linux. Attempting to install it on a server with many other things already installed may not work properly due to conflicts. Depending on where you're installing meza you'll have different initial setup steps. The following environments have been tested.

* [Setup Digital Ocean](manual/SetupDigitalOcean.md)
* [Setup VirtualBox](manual/1.0-SettingUpVirtualBox.md)

## Running the setup script

Login to your server and run the following:

```
curl -LO https://raw.githubusercontent.com/enterprisemediawiki/meza/master/scripts/install.sh
sudo bash install.sh
```

This script will retrieve a script from the meza repository, which will subsequently retrieve the entire meza repository. The script will ask you several questions regarding how to setup your MediaWiki environment. The parameters requested are:

* **Git branch**: The branch of meza to use. This is mostly for testing. Type "master" in most cases.
* **GitHub Token**: This allows you to download more things from GitHub than you would normally. Using the default is fine.
* **MySQL password**: Pick a good, secure password for MySQL root user
* **domain or IP address**: If you'll access your wiki at http://example.com, your type `example.com`. If you'll access it at http://192.168.56.56, type `192.168.56.56`.
* **Install with git**: Type `y`. You want to install with git.
* Setup of self-signed SSL certificate (for access over https): Enter location, organization and administrator info. For the sake of development enter any value for these fields, as your choices don't really matter. For the sake of a production server you should not be relying upon a self-signed certificate anyway. Generate the certificate with any choices, and replace with a trusted certificate after installation is complete.

## See Also

* [Creating and importing wikis](manual/AddingWikis.md)
* [Accessing Elasticsearch plugins](manual/ElasticsearchPlugins.md)
* [Installing additional extensions](manual/installing-additional-extensions.md)
* [Directory structure overview](manual/DirectoryStructure.md)

## Contributing
If you'd like to contribute to this project, please see [this guide on how to help](CONTRIBUTING.md).
