#!/bin/sh
#
# Get current usage of /opt, send it to slack webhook
# 
# Add this script as a scheduled task via crontab
# 0 10 * * * /opt/meza/scripts/opt-space-usage.sh
# Make sure permissions are set so the cron user has permission to execute this script

# webhook
webhook="https://hooks.slack.com/services/tbd"

# TO-DO this needs to be modified after #435 is merged
# get db root user password
if [ -f "/opt/meza/config/local/remote-wiki-config.sh" ]; then
    source "/opt/meza/config/local/remote-wiki-config.sh"
fi

# get all the dataz
datetime=$(date "+%Y%m%d%H%M%S")
dayofweek=$(date +%u)
hour=$(date +%H)
minute=$(date +%M)
mount_name=`cat /proc/mounts | grep "/opt" | awk '{print $1;}'`
space_total=`df | grep "$mount_name" | awk '{print $2;}'`
space_used=`df | grep "$mount_name" | awk '{print $3;}'`
space_remain=`df | grep "$mount_name" | awk '{print $4;}'`
space_used_percent=`df | grep "$mount_name" | awk '{print $5;}'`

# add data point to database
mysql -u root "--password=${mysql_root_pass}" -e"CREATE DATABASE IF NOT EXISTS server; use server; CREATE TABLE IF NOT EXISTS opt_space (datetime BIGINT, PRIMARY KEY (datetime), space_total BIGINT, space_used BIGINT); INSERT INTO opt_space (datetime, space_total, space_used) VALUES ('$datetime', $space_total, $space_used);"


# Create Slack message
msg="/opt usage: $space_used of $space_total KB\n\t$space_used_percent used\n\t$space_remain KB remain"

# Send Slack message
bash /opt/meza/scripts/slack.sh "$webhook" "Disk space remaining" "$msg"

