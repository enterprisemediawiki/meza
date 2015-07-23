# Meza1

Meza1 configures a CentOS/RedHat server with a complete enterprise MediaWiki installation.

## Server setup 

If you're installing on an existing server (or cloud hosting like [Digital Ocean](https://digitalocean.com), which we use) then you can probably skip this section. If you're installing on a virtual machine then perform one of the following:

* [Setup VirtualBox](manual/1.0-SettingUpVirtualBox.md)
* "Setup VMWare" steps to come

## Running the setup script

Login to your server and run the following:

```
cd ~
wget https://raw.githubusercontent.com/enterprisemediawiki/Meza1/master/client_files/install.sh
sudo bash install.sh
```

This script will retrieve a script from the Meza1 repository, which will subsequently retrieve the entire Meza1 repository. The script will ask you several questions regarding how to setup your MediaWiki environment. The parameters requested are:

* **Architecture**: Whether you're using 32-bit or 64-bit
* **PHP version**: Right now, use 5.4.42. In the future more versions will be supported
* **MySQL password**: Pick a good, secure password for MySQL root user
* **Wiki database name**: Pick something without any spaces, like "wiki_main"
* **Wiki name**: The name of your wiki, like "Main Wiki"
* **Admin name** and **password**: The username and password for a wiki admin account
* **Git branch**: The branch of Meza1 to use. This is mostly for testing. Type "master" in most cases.

## Manual Install
While the goal is to have an entirely scripted install of CentOS and the entire MediaWiki platform and dependencies, we started with just [manual instructions](manual/README.md). We haven't used these in a while, and they'll probably be removed at some point. Use at your own risk.
