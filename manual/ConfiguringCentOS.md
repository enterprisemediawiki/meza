# Configuring CentOS
This manual explains how to do initial setup of CentOS. It is 

## Using yum
Adding a -y option with yum keeps you from having to say "yes" to each install

## Setup networking
Setup your eth0 networking adapter. Change directory (cd) into your network-scripts directory:

```
cd /etc/sysconfig/network-scripts
```

Then edit your ifcfg-eth0 file:

```
vi ifcfg-eth0
```

And make it look like this:

```
DEVICE=eth0
HWADDR=<DEPENDENT ON YOUR SYSTEM>
TYPE=Ethernet
UUID=<DEPENDENT ON YOUR SYSTEM>
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=dhcp
```

Then check your eth1 (the "cat" command will display the contents of your eth1 file)

```
cat ifcfg-eth1
```

This should return "No such file or directory". We'll need to add it, but first run:

```
ifconfig eth1
```

The text that prints should include a first line including something like:

```
HWaddr 12:34:56:78:90:AB
```

Copy this address somewhere for later. **Copy the one from your computer, not what is written above.** 

```
vi ifcfg-eth1
```

Edit the file so it looks like what you have below, pasting in the hardware address you copied when you ran "ifconfig eth1" above.

```
DEVICE=eth1
HWADDR=<PASTE YOUR HWADDR HERE>
IPADDR=192.168.56.56
NETMASK=255.255.255.0
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=static
```

## Restart networking
Restart your networking service to make all your changes take effect:

```
service network restart
```

__Note: The first time I ran the above restart command, and attempted to ping google.com afterwards, the ping failed. I had hit "p" prematurely, when the restart was still running. I'm not sure if that was why. I re-ran "service network restart" and then the ping was successful.__

**Create a snapshot**

## Update yum
To make sure eveything is up-to-date, run yum update:

```
yum -y update
```

Note: this takes a little while.


## Setup SSH
To allow your VirtualBox client OS, CentOS, handle incoming SSH, run the following command:

```
yum -y install openssh-server openssh-clients
chkconfig sshd on
service sshd start
```

Port forwarding must be setup in your VirtualBox settings for ssh to work (we think). If you did not already do this in the [Setting up VirtualBox](SettingUpVirtualBox.md) chapter, do it now.

## SSH into your virtual machine
Using putty if you're on windows. SSH into 192.168.56.56 using your "root" user and password. If this works, then...**Create a snapshot**.


## Configure iptables
In order to access your VM from your host via HTTP, you'll need to open port 80. This requires you to edit "iptables".


Allow HTTP (port 80) on eth1 (the host-only adapter)
```bash
iptables -I INPUT 5 -i eth1 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
```

Save the changes to iptables so it survives reboot
```bash
service iptables save
```

This works for in this initial setup, but in the future we should consider a [method to define entire iptables config](http://blog.astaz3l.com/2015/03/06/secure-firewall-for-centos/).


## Install wget and Apache
There's no particular reason to install wget at this time, but you'll need it at some point and it was useful to the author when troubleshooting whether Apache was serving content.

```bash
yum -y install wget
yum -y install httpd
```

Start Apache:

```
chkconfig httpd on
/etc/init.d/httpd start
```


Create an index.html file at your webserver root:

```
cd /var/www/html
vi index.html
```

Add whatever content you want to the file, like:

```
<h1>Hello, World!<h1>
```

Navigate to http://192.168.56.56 from your host machine. If you're successful then Apache is working and your VM is serving over HTTP. Congratulations. **Create a snapshot**.

