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

See: [INSTALL PHP 5.4 on CentOS 6.2](http://benramsey.com/blog/2012/03/build-php-54-on-centos-62/)


### Current planning

There is no yum package "libmcrypt-devel" (or libmcrypt, for that matter). Must install it manually by doing the following. See http://benramsey.com/blog/2012/03/build-php-54-on-centos-62/ for more info


```
wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
rpm -K rpmforge-release-0.5.2-2.el6.rf.*.rpm # Verifies the package
rpm -i rpmforge-release-0.5.2-2.el6.rf.*.rpm
yum install libmcrypt-devel
```

To install other PHP requirements, perform the following. First should determine what all of them do and figure out if they're needed. Also check to see if they actually install via yum...would totally have missed libmcrypt-devel.

```
yum install \
	curl-devel \
	libc-client-devel.i686 \
	libc-client-devel \
    libxml2-devel \
    httpd-devel \
    libXpm-devel \
    gmp-devel \
    libicu-devel \
    t1lib-devel \
    aspell-devel \
    openssl-devel \
    bzip2-devel \
    libcurl-devel \
    libjpeg-devel \
    libvpx-devel \
    libpng-devel \
    freetype-devel \
    readline-devel \
    libtidy-devel \
```

Download PHP. This is for PHP 5.4. Check into MediaWiki's and SMW's requirements and figure out what makes sense to download. 5.5? 5.6?

```
wget http://www.php.net/get/php-5.4.0.tar.bz2/from/this/mirror
tar jxf php-5.4.0.tar.bz2
cd php-5.4.0/
```

Configure and make PHP. See if these all make sense. Try to figure out if there are any else we need. Look at the mod2 phpinfo().

```
./configure \
	--enable-bcmath \
	--with-bz2 \
	--enable-calendar \
	--with-curl \
	--enable-exif \
	--enable-ftp \
	--with-gd \
	--with-jpeg-dir \
	--with-png-dir \
	--with-freetype-dir \
	--enable-gd-native-ttf \
	--with-imap \
	--with-imap-ssl \
	--with-kerberos \
	--enable-mbstring \
	--with-mcrypt \
	--with-mhash \
	--with-mysql \
	--with-mysqli \
	--with-openssl \
	--with-pcre-regex \
	--with-pdo-mysql \
	--with-zlib-dir \
	--with-regex \
	--enable-sysvsem \
	--enable-sysvshm \
	--enable-sysvmsg \
	--enable-soap \
	--enable-sockets \
	--with-xmlrpc \
	--enable-zip \
	--with-zlib \
	--enable-inline-optimization \
	--enable-mbregex \
	--enable-opcache \
	--enable-fpm \
	--prefix=/usr/local/php
make
make install
```


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
