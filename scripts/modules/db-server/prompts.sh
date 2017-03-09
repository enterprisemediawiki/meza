#!/bin/sh

# passwords for root and wiki user
meza prompt_secure  mysql_root_pass   "$MSG_prompt_mysql_root_pass"
meza prompt_secure  db_password       "$MSG_prompt_db_password"
# FIXME: This shouldn't always be here...really it should be auto-generated I think.
meza prompt_secure  db_slave_password "$MSG_prompt_db_slave_password"

# this server's IP address
meza prompt         server_ip_address "$MSG_prompt_server_ip_address"

# space-separated list of app-server and db-server IP addresses
meza prompt         app_server_ips    "$MSG_prompt_app_server_ips"
source "$m_local_config_file" # re-source to get $server_ip_address as default
meza prompt         db_server_ips     "$MSG_prompt_db_server_ips"      "$server_ip_address"

