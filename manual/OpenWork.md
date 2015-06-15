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

## How to configure PHP
Consider adding the following to the configure step for PHP
```
    --with-apache2  ( has apxs2 )
    --with-zlib ( has with-zlib-dir )
    --with-dom
```

## Install MW from download

### Composer

```
cd ~/sources
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
```

### MW Option 1: Download tarball

```
wget https://releases.wikimedia.org/mediawiki/1.23/mediawiki-1.23.9.tar.gz -O wiki.tar.gz
tar -zxvf wiki.tar.gz
cd wiki
```


### MW Option 2: Git

```
cd /var/www/meza1/htdocs
git clone https://git.wikimedia.org/git/mediawiki/core.git wiki
cd wiki
composer update
cd skins
git clone https://git.wikimedia.org/git/mediawiki/skins/Vector.git
cd Vector
git checkout REL1_25
```



## Open issues

Two warnings from MW Installer:
* Warning: Could not find APC, XCache or WinCache.
* Warning: The intl PECL extension is not available to handle Unicode normalization, falling back to slow pure-PHP implementation.
