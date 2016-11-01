#!/bin/sh
#
# Setup config for backup script. This file required because it allows the same
# config variables to be used by both the source-server script(s) and the
# destination-server script(s).

# For test purposes, setup some unique values for these
backup_user_name="testuser4321"
temp_pub_key_path="/tmp/pubkey-$backup_user_name"
source_root_user="root" # root=root...duh, but keeping for easy changing later
