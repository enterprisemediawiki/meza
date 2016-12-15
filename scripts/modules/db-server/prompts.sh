#!/bin/sh

# passwords for root and wiki user
meza prompt_secure  mysql_root_pass   "$MSG_prompt_mysql_root_pass"
meza prompt_secure  db_password       "$MSG_prompt_db_password"

# space-separated list of app-server IP addresses
meza prompt         app_server_ips    "$MSG_prompt_app_server_ips"

# this server's IP address
meza prompt         server_ip_address "$MSG_prompt_server_ip_address"

# FIXME: This shouldn't always be here...really it should be auto-generated I think.
meza prompt         db_slave_password "FIXME i18n"
