# Meza1

## Manual Install
A repo to collect all our CentOS/RedHat setup info. The goal is to have an entirely scriptable install of CentOS and the entire MediaWiki platform and dependencies. For now there are [manual instructions in development](manual/README.md).

## Scripted Install
Scripted installation is in work. After [initial setup](manual/1.0-SettingUpVirtualBox.md) of your Virtual Box environment you have virtual machine with very little installed and that is incapable of SSH. Start your VM, then run the following three commands. Unfortunately you have to type them all manually, since your VM doesn't support copy/paste from the host at this point. Type carefully.

@todo: change "scripted" to "master" below during pull request

```bash
ifup eth0
yum -y install wget
wget -O - https://raw.githubusercontent.com/enterprisemediawiki/Meza1/scripted/setup.sh | bash
```

These three commands do the following:

**ifup eth0** turns on the NAT network adapter, allowing your virtual machine to connect to the internet. Provided you setup your VM as described in [initial setup](manual/1.0-SettingUpVirtualBox.md) this should complete successfully in a couple seconds.

**yum -y install wget** uses the CentOS package manager, yum, to install wget. wget allows your VM to retrieve files from networked resources. In this case we're going to use wget to retrieve a script file from the EnterpriseMediaWiki GitHub repository. Requires about a minute to run.

**wget ... bash** retrieves the setup script file, and pipes that script file into bash. This means that the script is executed once it is done downloading. It is recommended that you review the script beforehand to make sure you agree with all actions it takes. Requires about a minute or two to run.

Once you have run these commands your SSH should work. The IP address of your VM is one of the last lines of output of the wget command. Login from your host machine's terminal (or Putty if you're on Windows). Once you've confirmed you can use SSH it is recommended that you don't use the VM's user interface any longer. Just SSH. When you boot the VM in the future, hold shift while clicking "start" to boot without creating a user interface window.

Once you've logged in with SSH, move on to the LAMP setup scripts:

## Running the setup scripts

The scripts you'll need are below. They are downloaded during the initial setup.sh script you ran. I recommend running one at a time and taking a VirtualBox snapshot after each.

```bash
cd ~/sources/meza1/client_files
bash yums.sh <architecture>
bash apache.sh
bash php.sh
bash mysql.sh <mysql_root_password>
bash mediawiki.sh
```

For the yums.sh and mysql.sh scripts you must provide some options.

**yums.sh** requires you provide your platform architecture. This is either "32" or "64" (without the quotes). This means whether your computer architecture is 32-bit or 64-bit.

**mysql.sh** requires you to provide the mysql root user's password. This is probably not the most secure way to do this, but hey...it's just a development virtual machine, right?