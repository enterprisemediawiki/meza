#!/bin/bash
#
# Setup MySQL

print_title "Starting script mysql.sh"


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
if [ "$enterprise_linux_version" = "6" ]; then
	echo "Install MySQL for Enterprise Linux 6"
    yum -y install https://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm
else
	echo "Install MySQL for Enterprise Linux 7"
	yum -y install https://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
fi


#
# Install MySQL server
#
yum -y install mysql-community-server


#
# Setup storage of MySQL data in /opt/meza/data/mysql
#
chown mysql:mysql "$m_meza/data/mysql"
rm /etc/my.cnf
ln -s "$m_config/core/my.cnf" /etc/my.cnf


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
