# Meza1
A repo to collect all our CentOS/RedHat setup info

## Setting up the VirtualBox
Add steps for how to configure the VM. Add info about 32-bit requirement for James' laptop.

Make sure your networks are setup so Adapter 1 is NAT and Adapter 2 is Host-Only. These will correspond to eth0 and eth1, respectively.


## Installing CentOS
Add steps

## Configuring CentOS

See this [running list of notes(CentOS_Notes.md)

### Using yum
Adding a -y option with yum keeps you from having to say "yes" to each install

### Setup networking
vi /etc/sysconfig/network-scripts/ifcfg-eth0

Make sure onboot = yes and ...

### Install wget and Apache
```bash
yum install wget
yum install httpd
```


