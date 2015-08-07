#!/bin/bash
#
# Setup MySQL

bash printTitle.sh "Begin $0"


#
# Prompt for password
#
while [ -z "$mysql_root_pass" ]
do
echo -e "\n\n\n\nChoose a MySQL root password and press [ENTER]: "
read -s mysql_root_pass
done


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
mysqladmin -u root password "$mysql_root_pass"


#
# Login to root
#
mysql -u root "--password=$mysql_root_pass" -e"DELETE FROM mysql.user WHERE user=''; DELETE FROM mysql.user WHERE user='root' AND host NOT IN ('localhost', '127.0.0.1', '::1'); DROP DATABASE test;"


echo -e "\n\nMySQL setup complete\n"
