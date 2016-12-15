#!/bin/sh
#
# Setup slave server

master_db_ip=`echo "$db_server_ips" | awk '{print $1;}'`

# in my.cnf
my_cnf_additions=`cat <<EOF

# Setup for DB_SLAVE
server-id = $db_slave_id
master-host = $master_db_ip
master-user = $m_db_slave_user
master-password = $db_slave_password
master-connect-retry = 60

EOF`
echo "$my_cnf_additions" > /root/tmpSlaveDBfileForReplication

# find [mysqld] in my.cnf, add replication info from above
sed -i -e '/\[mysqld\]/ r /root/tmpSlaveDBfileForReplication' /etc/my.cnf
rm /root/tmpSlaveDBfileForReplication # remove temp file


# source replication file
mysql -u root "--password=$mysql_root_pass" < "$m_db_replication_dump_file"

# restart mariadb to pick up my.cnf changes
systemctl restart mariadb

# Get replication log info transferred from DB_MASTER
master_log_file=`cat "m_db_replication_log_file"`
master_log_pos=`cat "m_db_replication_log_pos"`

# Run queries to setup replication
query=`cat <<EOF
	SLAVE STOP;
	CHANGE MASTER TO MASTER_HOST='$master_db_ip',
		MASTER_USER='$m_db_slave_user',
		MASTER_PASSWORD='$db_slave_password',
		MASTER_LOG_FILE='$master_log_file',
		MASTER_LOG_POS=$master_log_pos;
	START SLAVE;
	SHOW SLAVE STATUS
EOF`
echo
echo "Running query for slave DB setup"
mysql -u root "--password=$mysql_root_pass" -e"$query"

