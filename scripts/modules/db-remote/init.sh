#!/bin/sh
#
# Modifies the db-server module to make it serve remotely

# Make root able to access from App Server
mysql -u root "--password=$mysql_root_pass" -e"CREATE USER 'root'@'$mw_api_domain' IDENTIFIED BY '$mysql_root_pass'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'$mw_api_domain'; FLUSH PRIVILEGES;"

# remote DB servers need to be accessible
sed -i "s/#bind-address/bind-address = $server_ip_address/" /etc/my.cnf

# open up firewall for DB port
firewall-cmd --permanent --add-service=mysql
firewall-cmd --reload

systemctl restart mariadb
