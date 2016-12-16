#!/bin/sh

meza prompt        db_server_ips     "$MSG_prompt_db_server_ips"
meza prompt_secure db_password       "$MSG_prompt_db_password"
meza prompt_secure db_slave_password "$MSG_prompt_db_slave_password"
meza prompt        db_slave_id       "$MSG_prompt_db_slave_id"
