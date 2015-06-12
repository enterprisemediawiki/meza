# Configuring CentOS


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

## Install wget and Apache
```bash
yum install wget
yum install httpd
```


