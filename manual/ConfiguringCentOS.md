# Configuring CentOS
This manual explains how to do initial setup of CentOS. It is 

## Using yum
Adding a -y option with yum keeps you from having to say "yes" to each install

## Setup networking
Setup your eth0 networking adapter-thing:

```
vi /etc/sysconfig/network-scripts/ifcfg-eth0
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
cat /etc/sysconfig/network-scripts/ifcfg-eth1
```

This should be blank. Before adding it, run:

```
ifconfig eth1
```

The text that prints should include a first line including something like:

```
HWaddr 08:00:27:39:12:6C
```

Copy this address somewhere for later. Then create your eth1 config:

```
vi /etc/sysconfig/network-scripts/ifcfg-eth1
```

Add add to it the following, pasting in the hardware address you copied above.

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


## Setup SSH
To allow your VirtualBox client OS, CentOS, handle incoming SSH, run the following command:

```
yum -y install openssh-server openssh-clients
chkconfig sshd on
service sshd start
```

Port forwarding must be setup in your VirtualBox settings for ssh to work (we think). If you did not already do this in the [Setting up VirtualBox](SettingUpVirtualBox.md) chapter, do it now.


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
```bash
yum install wget
yum install httpd
```


