#!/bin/bash
#
# Setup MySQL


#
# Exit if no password defined
#
if [ -z "$1" ]; then
    echo "No password defined for MySQL root user"
    exit 1
fi


#
# Install MySQL repo
#
yum -y install http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm


#
# Install MySQL server
#
yum -y install mysql-community-server


#
# Start MySQL service
#
chkconfig mysqld on
service mysqld start


#
# Set root password. Must be specified
#
mysqladmin -u root password "$1"


#
# Login to root
#
mysql -u root "--password=$1" -e"DELETE FROM mysql.user WHERE user=''; DELETE FROM mysql.user WHERE user='root' AND host NOT IN ('localhost', '127.0.0.1', '::1'); DROP DATABASE test;"


echo -e "\n\nMySQL setup complete\n"
