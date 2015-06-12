CentOS VM Setup
===============

basically initial but after bridge setup: /etc/sysconfig/network-scripts/ifcfg-eth0

DEVICE=eth0
HWADDR=<DONT CHANGE>
TYPE=Ethernet
UUID=<LONG STRING>
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=dhcp


https://extr3metech.wordpress.com/2012/10/25/centos-6-3-installation-in-virtual-box-with-screenshots/
https://extr3metech.wordpress.com/2013/05/23/configuring-network-in-centos-6-3-virtual-box-screenshots/


Install Apache: http://www.cyberciti.biz/faq/linux-install-and-start-apache-httpd/


yum install httpd
yum install php   <-- does php 5.3.x   WANT php 5.5 minimum
yum install wget




vi /etc/network/interfaces


# The loopback network interface
auto lo
iface lo inet loopback

# NAT interface
auto eth0
iface eth0 inet dhcp

# Host-only interface
auto eth1
iface eth1 inet static
        address         192.168.56.20
        netmask         255.255.255.0
        network         192.168.56.0
        broadcast       192.168.56.255



First attempt to add a ifcfg-eth1 file
https://www.centos.org/docs/5/html/Installation_Guide-en-US/s1-s390info-addnetdevice.html

HWADDR 08:00:27:39:12:6C



Open http port ( 80 ) in iptables on CentOS
	http://www.binarytides.com/open-http-port-iptables-centos/


Allow HTTP (port 80) on eth1 (the host-only adapter)
```bash
iptables -I INPUT 5 -i eth1 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
```

Save the changes to iptables so it survives reboot
```bash
service iptables save
```


yum remove php-cli
yum remove php-common






Another method for handling iptables, from: http://benramsey.com/blog/2012/03/build-php-54-on-centos-62/

sed -i '/22/ i -A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT' /etc/sysconfig/iptables
sed -i '/22/ i -A INPUT -m state --state NEW -m tcp -p tcp --dport 8000 -j ACCEPT' /etc/sysconfig/iptables
/etc/init.d/iptables restart



INSTALL PHP 5.4 on CentOS 6.2
http://benramsey.com/blog/2012/03/build-php-54-on-centos-62/


USE -y option with "yum" to not ask you to choose yes


yum -y install openssh-server openssh-clients
chkconfig sshd on
service sshd start
