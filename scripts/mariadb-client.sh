#!/bin/bash
#
# Setup MariaDB client

print_title "Starting script mariadb-client.sh"


#
# Install MariaDB server
#
yum -y install mariadb


echo -e "\n\nMariaDB client setup complete\n"
