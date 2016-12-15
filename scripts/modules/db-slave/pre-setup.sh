#!/bin/bash
#
# Need to check to make sure DB_MASTER info is present before setup
#

for file in $m_db_replication_dump_file $m_db_replication_log_file $m_db_replication_log_pos; do

	if [ ! -f "$file" ]; then
		echo
		echo "Missing file required to initiate master/slave replication. Missing:"
		echo "$file"
		echo
		exit 1
	fi
done
