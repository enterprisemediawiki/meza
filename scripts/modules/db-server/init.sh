#!/bin/bash
#
# Setup database

#
# Start MariaDB service
#
systemctl enable mariadb
systemctl start mariadb

# make sure mysql owns this directory
chown mysql:mysql "$m_meza/data/mariadb"

# move existing directory contents (which were created when doing
# systemctl start mariadb above) so SELinux keeps same constraints
mv /var/lib/mysql/* /opt/meza/data/mariadb
rm /opt/meza/data/mariadb/mysql.sock # keeping this in standard location

# Setup mariadb configuration
# (e.g storage of data in /opt/meza/data/mysql)
mv /etc/my.cnf /etc/my.default.cnf
cp "$m_config/template/my.cnf" /etc/my.cnf

# Restart mariadb with new config
systemctl restart mariadb


# configure SELinux
# chcon -Rt mysqld_db_t "$m_meza/data/mariadb"
# chcon -Ru system_u "$m_meza/data/mariadb"




mount /database
mkdir /database/db
chcon -Rt mysqld_db_t /database/db
chcon -Ru system_u /database/db
chown -R mysql:mysql /database/db
systemctl start mariadb



#
# Set root password. Must be specified
#
mysqladmin -u root password "$mysql_root_pass"


#
# Remove unneeded root access capabilities and remove test database
#
query=`cat <<EOF
	DELETE FROM mysql.user WHERE user='';
	DELETE FROM mysql.user WHERE user='root' AND host NOT IN ('localhost', '127.0.0.1', '::1');
	DROP DATABASE test;
	FLUSH PRIVILEGES;
EOF`
mysql -u root "--password=$mysql_root_pass" -e"$query"


#
# Make application user able to access from app server(s)
# Note, for replication user must have REPLICATION CLIENT privilege per MW docs
#
for app_server_ip in $app_server_ips; do

	query=`cat <<EOF
		CREATE USER '$m_wiki_app_user'@'$app_server_ip' IDENTIFIED BY '$db_password';
		GRANT ALL PRIVILEGES ON *.* TO '$m_wiki_app_user'@'$app_server_ip';
		FLUSH PRIVILEGES;
EOF`
	mysql -u root "--password=$mysql_root_pass" -e"$query"

done



echo -e "\n\nMySQL server setup complete\n"
