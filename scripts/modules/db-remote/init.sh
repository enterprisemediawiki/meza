#!/bin/sh
#
# Modifies the db-server module to make it serve remotely

# remote DB servers need to be accessible
sed -i "s/#bind-address/bind-address = $server_ip_address/" /etc/my.cnf

# open up firewall for DB port
# FIXME: make this only open to app servers
# firewall-cmd --permanent --add-service=mysql
# firewall-cmd --reload

for app_server_ip in $app_server_ips; do

	echo "adding firewall rule for mysql for $app_server_ip"
	firewall-cmd --permanent "--zone=$m_private_networking_zone" --add-rich-rule=" \
		rule family=\"ipv4\" \
		source address=\"$app_server_ip/32\" \
		service name=\"mysql\" accept"

done

firewall-cmd --reload

systemctl restart mariadb
