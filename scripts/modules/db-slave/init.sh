#!/bin/sh
#
# Setup slave server

# add server ID for DB_SLAVE
sed -i  "s/\[mysqld\]/\[mysqld\]\n\n# Setup for DB_SLAVE\nserver-id = $db_slave_id/" /etc/my.cnf

# source replication file
mysql -u root "--password=$mysql_root_pass" < "$m_db_replication_dump_file"

# restart mariadb to pick up my.cnf changes
systemctl restart mariadb

# Get replication log info transferred from DB_MASTER
master_log_file=`cat "$m_db_replication_log_file"`
master_log_pos=`cat "$m_db_replication_log_pos"`

# Run queries to setup replication
master_db_ip=`echo "$db_server_ips" | awk '{print $1;}'`
query=`cat <<EOF
	SLAVE STOP;
	CHANGE MASTER TO MASTER_HOST='$master_db_ip',
		MASTER_USER='$m_db_slave_user',
		MASTER_PASSWORD='$db_slave_password',
		MASTER_LOG_FILE='$master_log_file',
		MASTER_LOG_POS=$master_log_pos;
	START SLAVE;
EOF`
echo
echo "Running query for slave DB setup"
mysql -u root "--password=$mysql_root_pass" -e"$query"

slave_status=`mysql -u root "--password=$mysql_root_pass" -e"SHOW SLAVE STATUS\G" | sed -n -e 's/^.*Slave_IO_State: //p'`
if [ "$slave_status" = "Waiting for master to send event" ]; then
	echo "Slave status good: $slave_status";
fi
