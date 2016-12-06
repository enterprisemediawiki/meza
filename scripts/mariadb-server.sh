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
mv /etc/my.default.cnf
cp "$m_config/template/my.cnf" /etc/my.cnf

if [ "$is_remote_db_server"  = true ]; then

	# remote DB servers need to be accessible
	sed -i "s/bind_ip_address/$server_ip_address/" /etc/my.cnf

else
	# if not having a remote DB server, no need to open up
	sed -i "s/bind-address/#bind-address/" /etc/my.cnf
fi


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


if [ "$is_remote_db_server" = "true" ]; then

	# Make root able to access from App Server
	mysql -u root "--password=$mysql_root_pass" -e"CREATE USER 'root'@'$mw_api_domain' IDENTIFIED BY '$mysql_root_pass'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'$mw_api_domain'; FLUSH PRIVILEGES;"

	# open up firewall for DB port
	firewall-cmd --permanent --add-service=mysql
	firewall-cmd --reload

fi

echo -e "\n\nMySQL setup complete\n"
