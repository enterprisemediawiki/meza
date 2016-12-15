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

# configure SELinux. These may be needed if not moving datadir after starting
# it in the stock position
# chcon -Rt mysqld_db_t "$m_meza/data/mariadb"
# chcon -Ru system_u "$m_meza/data/mariadb"

# Restart mariadb with new config
systemctl restart mariadb


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
echo "Performing queries:"
echo "$query"
mysql -u root "--password=$mysql_root_pass" -e"$query"


#
# Make application user able to access from app server(s)
# Note, for replication user must have REPLICATION CLIENT privilege per MW docs
#
for app_server_ip in $app_server_ips; do

	echo "Adding mysql privileges for $app_server_ip"
	query=`cat <<EOF
		CREATE USER '$m_wiki_app_user'@'$app_server_ip' IDENTIFIED BY '$db_password';
		GRANT ALL PRIVILEGES ON *.* TO '$m_wiki_app_user'@'$app_server_ip';
		FLUSH PRIVILEGES;
EOF`
	mysql -u root "--password=$mysql_root_pass" -e"$query"

done


#
# If $db_server_ips is more than one IP long, e.g. if this is the master server
# and there ARE more servers to act as slaves, then setup for slaves.
#
if [ `mf_countargs $db_server_ips` -gt 1 ]; then

	echo
	echo "More than one DB server specified, setting up slaves."

	# Make sure variable has whitespace removed prior to splitting on spaces
	db_server_ips=`mf_trimwhitespace $db_server_ips`

	# Split server IPs on spaces, remove first IP
	db_slave_ips=`echo "$db_server_ips" | cut -d " " -f2-`


	# Loop through all DB_SLAVEs and apply settings
	for db_slave_ip in $db_slave_ips; do

		# FIXME: this will setup a rule allowing access from this server's IP.
		#        there's nothing inherently wrong with that, but it's unnecessary.
		#        This is simpler, but could be made better by skipping the first
		#        IP, which is DB_MASTER and thus this server.

		echo "Add firewall rule for mysql for DB_SLAVE: $db_slave_ip"
		echo "    Reason: Allow DB_SLAVE replication"
		firewall-cmd --permanent "--zone=$m_private_networking_zone" --add-rich-rule=" \
			rule family=\"ipv4\" \
			source address=\"$db_slave_ip/32\" \
			service name=\"mysql\" accept"

		# Create replication user(s)
		echo "Add database privileges for DB_SLAVE: $db_slave_ip"
		echo "    Reason: Allow DB_SLAVE replication"
		source "$m_scripts/shell-functions/db-master.sh"
		mf_createDBuser "$m_db_slave_user" "$db_slave_ip" "$db_slave_password" "REPLICATION SLAVE"

	done

	# Add DB master stuff to my.cnf
	# FIXME: Should this be present anyway? Regardless of if there are slaves?
	sed -i "s/\[mysqld\]/\[mysqld\]\n\n# Master DB setup\nserver-id = 1\nlog-bin = mysql-bin\nbinlog-ignore-db = \"mysql\"/" /etc/my.cnf

	systemctl restart mariadb

	# Lock database prior to mysqldump
	mysql -u root "--password=$mysql_root_pass" -e"FLUSH TABLES WITH READ LOCK;"

	# Get log and position to inform slave databases
	db_master_status=`mysql -u root "--password=$mysql_root_pass" -e"SHOW MASTER STATUS;" | sed -n '2p'`
	master_log_file=`echo "$db_master_status" | awk '{print $1;}'`
	master_log_pos=`echo "$db_master_status" | awk '{print $2;}'`
	# FIXME: For now, just put log and position files someplace easy to get
	# to later. Should send this info over to slaves somehow automated.
	echo "$master_log_file" > "$m_db_replication_log_file"
	echo "$master_log_pos" > "$m_db_replication_log_pos"


	# Get SQL file for slaves
	mysqldump -u root "--password=$mysql_root_pass" --databases $(
		mysql -u root "--password=$mysql_root_pass" -N information_schema -e "SELECT DISTINCT(TABLE_SCHEMA) FROM tables WHERE TABLE_SCHEMA LIKE 'wiki_%'"
	) > "$m_db_replication_dump_file"

	# Unlock database
	mysql -u root "--password=$mysql_root_pass" -e"UNLOCK TABLES;"


	# Loop through all DB_SLAVEs and apply settings
	# FIXME: Need method to pass this file from master to slave(s). For now
	# just do it manually, but probably if using Ansible or something will
	# need the configuration master (not DB master) to grab the file then
	# distribute to DB_SLAVE(s)
	# for db_slave_ip in $db_slave_ips; do
	# 	scp "$m_db_replication_dump_file" [private-IP-of-db02]:/root/
	# done

# No slave servers
else
	echo
	echo "No slave servers being setup";
fi


echo -e "\n\nMySQL server setup complete\n"
