#!/bin/bash
#
# Setup database


#
# Setup storage of MySQL data in /opt/meza/data/mysql
#
chown mysql:mysql "$m_meza/data/mariadb"
mv /etc/my.default.cnf
cp "$m_config/template/my.cnf" /etc/my.cnf

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
