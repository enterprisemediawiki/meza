Setup a RedHat Dev VM
=====================

1. Download the DVD.iso RedHat 7 image on the [Red Hat downloads page](https://developers.redhat.com/products/rhel/download/). When you attempt to download for the first time you'll have to generate a Red Hat account. You're going to have to create a username and password anyway, so there doesn't appear to be a strong need to use a linked account (e.g. Google, Github).
2. Place the ISO in your home folder and use `create-vm.sh` as described on the [VirtualBox setup instructions](1.0-SettingUpVirtualBox.md)
3. Install the Red Hat Enterprise Linux operating system in the same way you install CentOS
4. After the OS is installed, when you've booted into your OS command line, start with the same command as on CentOS: `sudo ifup enp0s3` (starts networking)
5. Next, setup your RedHat subscription with `sudo subscription-manager register --username <username> --password <password> --auto-attach` using your username and password for your RedHat developer account
6. Continue with normal CentOS steps:
  1. `curl -L getmeza.org > doit`
  2. `sudo bash doit`
  3. (optional) `cd /opt/meza && sudo git checkout <branch>` if you're testing a new branch
  4. `sudo meza setup dev-networking`
  5. SSH into your VM
  6. `sudo meza deploy monolith`
