# Open Work
This is a list of things we're working on.

## Install a recent install of PHP (preferably able to choose version)
Running the following installs PHP 5.3:

```
yum install php
```

We want 5.5 at a minimum. Note that to remove PHP with yum you may have to do the following:

```
yum remove php
yum remove php-cli
yum remove php-common
```

### See: INSTALL PHP 5.4 on CentOS 6.2
http://benramsey.com/blog/2012/03/build-php-54-on-centos-62/


## Install MySQL
Haven't tried yet.


## Create iptables setup script




### More on iptables

Another method for handling iptables, from: http://benramsey.com/blog/2012/03/build-php-54-on-centos-62/

Consider also this method of editing iptables, and also opening up port 8000

```
sed -i '/22/ i -A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT' /etc/sysconfig/iptables
sed -i '/22/ i -A INPUT -m state --state NEW -m tcp -p tcp --dport 8000 -j ACCEPT' /etc/sysconfig/iptables
/etc/init.d/iptables restart
```
