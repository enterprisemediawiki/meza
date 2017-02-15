#!/bin/sh

# Check if database servers are up
for db_server_ip in $db_server_ips; do

	if mysql -u "$m_wiki_app_user" -h "$db_server_ip" "--password=$db_password" -e"select version();" | grep -q "MariaDB"; then
		echo "Successfully reached database at '$db_server_ip'"
	else
		echo "Unable to reach database at '$db_server_ip'"
		exit 1;
	fi

done
