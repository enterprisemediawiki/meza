#!/bin/bash
#
# Setup PHP

print_title "Starting script php.sh"


# Install IUS repository
yum -y install https://centos7.iuscommunity.org/ius-release.rpm

# Install yum-plugin-replace and replace the php packages with php56u packages:
# yum install -y yum-plugin-replace
# yum -y replace --replace-with php56u php

# Install php56u packages
yum install -y \
	php56u \
	php56u-cli \
	php56u-common \
	php56u-devel \
	php56u-gd \
	php56u-pecl-memcache \
	php56u-pspell \
	php56u-snmp \
	php56u-xml \
	php56u-xmlrpc \
	php56u-mysqlnd \
	php56u-pdo \
	php56u-pear \
	php56u-pecl-jsonc \
	php56u-process \
	php56u-bcmath \
	php56u-intl \
	php56u-opcache \
	php56u-soap \
	php56u-mbstring \
	php56u-mcrypt


#
# Initiate php.ini
#
mv /etc/php.ini /etc/php.ini.default
ln -s "$m_config/core/php.ini" /etc/php.ini


#
# Start webserver service
#
chkconfig httpd on
service httpd status
service httpd restart

# # Install PEAR Mail
pear install --alldeps Mail

echo -e "\n\nPHP has been setup.\n\nPlease use the web browser on your host computer to navigate to http://192.168.56.56/info.php to verify php is being executed."
