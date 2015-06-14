# Open Work
This is a list of things we're working on.


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

