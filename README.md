# Meza1

## Manual Install
A repo to collect all our CentOS/RedHat setup info. The goal is to have an entirely scriptable install of CentOS and the entire MediaWiki platform and dependencies. For now there are [manual instructions in development](manual/README.md).

## Scripted Install
Scripted installation is in work. After [initial setup](manual/1.0-SettingUpVirtualBox.md) of your Virtual Box environment you have virtual machine with very little installed and that is incapable of SSH. Start your VM, then run the following three commands. Unfortunately you have to type them all manually, since your VM doesn't support copy/paste from the host at this point. Type carefully.

```bash
ifup eth0
yum -y install wget
wget -O - https://raw.githubusercontent.com/enterprisemediawiki/Meza1/master/setup.sh | bash
```

These three commands do the following:

**ifup eth0** turns on the NAT network adapter, allowing your virtual machine to connect to the internet. Provided you setup your VM as described in [initial setup](manual/1.0-SettingUpVirtualBox.md) this should complete successfully in a couple seconds.

**yum -y install wget** uses the CentOS package manager, yum, to install wget. wget allows your VM to retrieve files from networked resources. In this case we're going to use wget to retrieve a script file from the EnterpriseMediaWiki GitHub repository.

**wget ... bash** retrieves the setup script file, and pipes that script file into bash. This means that the script is executed once it is done downloading. It is recommended that you review the script beforehand to make sure you agree with all actions it takes.
