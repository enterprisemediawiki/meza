#!/bin/sh

meza prompt        server_ip_address "Type IP address of this server"

# space-separated list of app-server IP addresses
meza prompt         app_server_ips    "$MSG_prompt_app_server_ips"
