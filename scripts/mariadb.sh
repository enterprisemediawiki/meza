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
# Install MariaDB server
#
yum -y install mariadb-server


#
# Setup storage of MySQL data in /opt/meza/data/mysql
#
chown mysql:mysql "$m_meza/data/mariadb"
rm /etc/my.cnf
ln -s "$m_config/core/my.cnf" /etc/my.cnf


#
# Start MariaDB service
#
systemctl enable mariadb
systemctl start mariadb


#
# Set root password. Must be specified
#
mysqladmin -u root password "$mysql_root_pass"


#
# Login to root
#
mysql -u root "--password=$mysql_root_pass" -e"DELETE FROM mysql.user WHERE user=''; DELETE FROM mysql.user WHERE user='root' AND host NOT IN ('localhost', '127.0.0.1', '::1'); DROP DATABASE test;"


echo -e "\n\nMySQL setup complete\n"
