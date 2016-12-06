#!/bin/bash
#
# Setup MariaDB

print_title "Starting script mariadb.sh"

if [ "$setup_database_server" = true ]; then
	source "$m_scripts/mariadb-master.sh"
else
	source "$m_scripts/mariadb-client.sh"

	# Check if master server is up
	if mysql -u "$remote_db_user" -h "$remote_db_server" "--password=$mysql_root_pass" -e"select version();" | grep -q "MariaDB"; then
		echo "Successfully reached database server"
	else
		echo "Unable to reach database server"
		exit 1;
	fi

	# create and sync slave servers
	# TBD
fi


echo -e "\n\nMySQL setup complete\n"
