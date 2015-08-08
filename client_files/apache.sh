#!/bin/bash
#
# Setup Apache webserver

bash printTitle.sh "Begin $0"


#
# Use pre-downloaded Apache httpd, Apache Portable Runtime (APR) and APR-util
#
# Sources:
# [1] http://www.us.apache.org/dist//httpd/
# [2] http://www.us.apache.org/dist//apr
#
httpd_version="2.4.16"
apr_version="1.5.2"
apr_util_version="1.5.4"


#
# Unpack Apache Webserver sources into ~/sources
# Unpack APR and APR Util into Apache Webserver /srclib directory
#
cd ~/sources/meza1/src
tar -zxvf "httpd-$httpd_version.tar.gz" -C /root/sources
cd "/root/sources/httpd-$httpd_version/srclib"
mkdir apr
mkdir apr-util
tar -zxvf "/root/sources/meza1/src/apr-$apr_version.tar.gz" -C "/root/sources/httpd-$httpd_version/srclib/apr" --strip-components 1
tar -zxvf "/root/sources/meza1/src/apr-util-$apr_util_version.tar.gz" -C "/root/sources/httpd-$httpd_version/srclib/apr-util" --strip-components 1




#
# Build Apache Webserver from source
#
cd "~/sources/httpd-$httpd_version"
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
# @todo: Issue #138
#
# Skip section (not titled) on httpd.conf "Supplemental configuration" 
# Skip section titled "httpd-mpm.conf" 
# Skip section titled "Vhosts for apache 2.4.12"
#
# @todo: figure out if this section is necessary For now skip section titled "httpd-security.conf"
#



# @todo: pick up from section "Modify config file"

#### NOT YET COMPLETE ####




cd /usr/local/apache2/conf

# update document root
sed -r -i 's/\/usr\/local\/apache2\/htdocs/\/var\/www\/meza1\/htdocs/g;' ./httpd.conf

# direct apache to execute PHP
cat ~/sources/meza1/client_files/httpd-conf-additions.conf >> ./httpd.conf

# serve index.php as default file
sed -r -i 's/DirectoryIndex\s*index.html/DirectoryIndex index.php index.html/g;' ./httpd.conf

# modify user that will handle web requests
sed -r -i 's/User\s*daemon/User apache/g;' ./httpd.conf
sed -r -i 's/Group\s*daemon/Group www/g;' ./httpd.conf

# create service script
cd /etc/init.d
cp ~/sources/meza1/client_files/initd_httpd.sh ./httpd
chmod +x /etc/init.d/httpd

# create logrotate file
cd /etc/logrotate.d
cp ~/sources/meza1/client_files/logrotated_httpd ./httpd

cd /var/www/meza1/htdocs
touch index.html
echo '<h1>It works!</h1><p>Congratulations, your Apache 2.4 webserver is running.</p>' > index.html

# Start webserver service
chkconfig httpd on
service httpd status
service httpd restart

echo -e "\n\nYour Apache 2.4 webserver has been setup.\n\nPlease use the web browser on your host computer to navigate to http://192.168.56.56 to test it out"

