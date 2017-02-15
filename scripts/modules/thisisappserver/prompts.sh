#!/bin/sh

# Prompt for server IP, then source config file and write same IP as MW domain
meza prompt server_ip_address "$MSG_prompt_server_ip_address"
source "$m_local_config_file"
meza config mw_api_domain "$server_ip_address"
