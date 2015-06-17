#!/bin/bash
#
# Setup Apache webserver

# Setup source directory
cd ~/sources

#
# Download Apache httpd, Apache Portable Runtime (APR) and APR-util
# Note that these links may break when new versions are released
# See httpd [1] and APR [2] list of files to confirm versions before running.
#
# [1] http://ftp.piotrkosoft.net/pub/mirrors/ftp.apache.org//httpd/
# [2] http://ftp.ps.pl/pub/apache//apr/
#
wget http://www.us.apache.org/dist//httpd/httpd-2.4.12.tar.gz
wget http://www.us.apache.org/dist//apr/apr-1.5.2.tar.gz
wget http://www.us.apache.org/dist//apr/apr-util-1.5.4.tar.gz


#
# Unpack and build Apache from source
#
tar -zxvf httpd-2.4.12.tar.gz
tar -zxvf apr-1.5.2.tar.gz
tar -zxvf apr-util-1.5.4.tar.gz
cp -r apr-1.5.2 httpd-2.4.12/srclib/apr
cp -r apr-util-1.5.4 httpd-2.4.12/srclib/apr-util
cd httpd-2.4.12
./configure --enable-ssl --enable-so --with-included-apr --with-mpm=event
make
make install


#
# Apache user
#
groupadd www
useradd -G www -r apache
chown -R apache:www /usr/local/apache2


#
# Setup document root
#
mkdir /var/www
mkdir /var/www/meza1
mkdir /var/www/meza1/htdocs
mkdir /var/www/meza1/logs
chown -R apache:www /var/www
chmod -R 775 /var/www


#
# Skip section (not titled) on httpd.conf "Supplemental configuration" 
# Skip section titled "httpd-mpm.conf" 
# Skip section titled "Vhosts for apache 2.4.12"
#
# @todo: figure out if this section is necessary For now skip section titled "httpd-security.conf"
#



# @todo: pick up from section "Modify config file"

#### NOT YET COMPLETE ####



