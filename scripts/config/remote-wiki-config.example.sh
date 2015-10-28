#!/bin/bash
#
# This is the example config file for the import-remote-wikis.sh script


mount_name="remote-meza"
remote_share="//example.com/some-directory"

# recommended not to set this value, so any user who has access to the share
# can use their own credentials
# remote_username="your-username"

# path from //example.com/some-directory to your wikis directory. Do not lead
# with a slash.
remote_wikis_path="htdocs/wikis"

# space-delimited list of wikis you want to import.
# If you want to import all wikis, do `which_wikis="IMPORT_ALL"`
which_wikis="wiki1 wiki2 wiki3"

# MySQL root password for local database
mysql_root_pass="some-password"

# Database configuration for remote (source) database
remote_db_server="database.example.com"
remote_db_username="database-user"
remote_db_password="database-password"
