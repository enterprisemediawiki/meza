#!/bin/bash
#
# Setup PHP

#
# Download PHP 5.6.10 source
#
cd ~/sources
wget http://php.net/get/php-5.6.10.tar.bz2/from/this/mirror -O php-5.6.10.tar.bz2
tar jxf php-5.6.10.tar.bz2
cd php-5.6.10/

#
# Configure, make, make install
#
./configure \
    --with-apxs2=/usr/local/apache2/bin/apxs \
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


#
# Add PHP to path
#
echo "export PATH=/usr/local/php/bin:\$PATH" > /etc/profile.d/php.sh


#
# Initiate php.ini
#
cp ~/sources/php-5.6.10/php.ini-development /usr/local/php/lib/php.ini


# Check and make sure php5_module is enabled?
# @todo: do we need this?
#LoadModule php5_module modules/libphp5.so

#
# Restart Apache
#
service httpd restart
