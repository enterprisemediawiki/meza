#!/bin/sh
#
# Modifies the db-server module to make it serve remotely

# remote DB servers need to be accessible
sed -i "s/#bind-address/bind-address = $server_ip_address/" /etc/my.cnf

# open up firewall for DB port
# FIXME: make this only open to app servers
firewall-cmd --permanent --add-service=mysql
firewall-cmd --reload

systemctl restart mariadb
