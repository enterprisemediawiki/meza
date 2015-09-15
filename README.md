# Meza1 v0.2.1

Meza1 configures a CentOS/RedHat server with a complete enterprise MediaWiki installation.

## Server setup

Depending on where you're installing Meza1 you'll have different initial setup steps. The following environments have been tested.

* [Setup Digital Ocean](manual/SetupDigitalOcean.md)
* [Setup VirtualBox](manual/1.0-SettingUpVirtualBox.md)
* [Setup VirtualBox on Windows](manual/1.0-SettingUpVirtualBoxWindows.md)
* "Setup VMWare" steps to come

## Running the setup script

Login to your server and run the following:

```
cd ~
wget https://raw.githubusercontent.com/enterprisemediawiki/Meza1/master/client_files/install.sh
sudo bash install.sh
```

This script will retrieve a script from the Meza1 repository, which will subsequently retrieve the entire Meza1 repository. The script will ask you several questions regarding how to setup your MediaWiki environment. The parameters requested are:

* **PHP version**: Right now, use 5.4.42. In the future more versions will be supported
* **MySQL password**: Pick a good, secure password for MySQL root user
* **Git branch**: The branch of Meza1 to use. This is mostly for testing. Type "master" in most cases.
* **http or https**: Will you access your website via http or https? If you don't know, do http.
* **domain or IP address**: If you'll access your wiki at http://example.com, your type `example.com`. If you'll access it at http://192.168.56.56, type `192.168.56.56`.
* **Install with git**: Type `y`. You want to install with git.

## Manual Install

While the goal is to have an entirely scripted install of CentOS and the entire MediaWiki platform and dependencies, we started with just [manual instructions](manual/README.md). We haven't used these in a while, and they'll probably be removed at some point. Use at your own risk.

## See Also

* [Creating and importing wikis](manual/AddingWikis.md)
