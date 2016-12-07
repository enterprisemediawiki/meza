#!/bin/sh

meza prompt        remote_db_server   "Type domain or IP address of remote DB"
meza prompt        remote_db_user     "Type user for remote DB"
meza prompt_secure remote_db_pass     "Type password for remote DB user"
