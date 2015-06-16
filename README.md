# Meza1

## Manual Install
A repo to collect all our CentOS/RedHat setup info. The goal is to have an entirely scriptable install of CentOS and the entire MediaWiki platform and dependencies. For now there are [manual instructions in development](manual/README.md).

## Scripted Install
Scripted installation is in work. After [initial setup](manual/1.0-SettingUpVirtualBox.md) of your Virtual Box environment you have virtual machine with very little installed and that is incapable of SSH. Start your VM, then run the following three commands. Unfortunately you have to type them all manually, since your VM doesn't support copy/paste from the host at this point. Type carefully

```bash
ifup eth0
yum -y install wget
wget -O - https://raw.githubusercontent.com/enterprisemediawiki/Meza1/scripted/setup.sh | bash
```
