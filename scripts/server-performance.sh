#!/bin/bash
#
# server-performance.sh
#
# Send an announcement to Slack reporting server performance
#
# Add this script as a scheduled task via crontab
# */10 * * * * /opt/meza/scripts/server-performance.sh
# Make sure permissions are set so the cron user has permission to execute this script

if [ "$(whoami)" != "root" ]; then
    echo "Try running this script with sudo: \"sudo server-performance.sh\""
    exit 1
fi

# If /usr/local/bin is not in PATH then add it
# Ref enterprisemediawiki/meza#68 "Run install.sh with non-root user"
if [[ $PATH != *"/usr/local/bin"* ]]; then
    PATH="/usr/local/bin:$PATH"
fi

source /opt/meza/config/core/config.sh

if [ -f "/opt/meza/config/local/remote-wiki-config.sh" ]; then
    source "/opt/meza/config/local/remote-wiki-config.sh"
fi

# Optional - Use this webhook instead of the one from remote-wiki-config.sh
# slackwebhook="<webhook>"

# get all the dataz
datetime=$(date "+%Y%m%d%H%M%S")
dayofweek=$(date +%u)
hour=$(date +%H)
minute=$(date +%M)
topdata=$(top -b -n 1)

jobs=0

cd /opt/meza/htdocs/wikis
for d in */
do
        wiki_id=${d%/}
        moreJobs=$(WIKI=$wiki_id php /opt/meza/htdocs/mediawiki/maintenance/showJobs.php)
        jobs=$(($jobs+$moreJobs))
done

topheader=$(echo "$topdata" | grep "load average")
# top - 15:36:28 up 48 days, 21:35,  1 user,  load average: 0.08, 0.16, 0.21
# remove "top - "
topheader=${topheader#top - }

# uptime
# TO-DO: Not sure how best to track uptime (consolidate into minutes?)

# 1-minute load average
loadavgall3=${topheader#*average: }
loadavg1=${loadavgall3%,*,*}
# 5-minute load average
loadavg5=${loadavgall3#*, }
loadavg5=${loadavg5%,*}
# 15-minute load average
loadavg15=${loadavgall3#*,*, }

topmemory=$(echo "$topdata" | grep "KiB Mem")
# KiB Mem : 16269056 total,   275304 free,  2177008 used, 13816744 buff/cache
topmemory2=$(echo "$topdata" | grep "avail Mem")
# KiB Swap:  3907580 total,  3655212 free,   252368 used.  4522976 avail Mem

# isolate total memory value
totalmemory=${topmemory#*KiB Mem : }
totalmemory=${totalmemory% total*}

# isolate available memory value
availmemory=${topmemory2#*used. }
availmemory=${availmemory% avail Mem*}

# calculate memory used
((memoryused = $totalmemory - $availmemory))

# calculate percent of total memory used
memorypercentused=$(echo print 100*${memoryused}/${totalmemory}. | python )
memorypercentused=$(printf "%0.1f\n" $memorypercentused)
# format a rounded version for use in comparison later
memorypercentusedrounded=$(printf "%.0f\n" $memorypercentused)

# Individual tasks
# PID user priority nice virtual resident shareable CPU% memory% time command
topmysql=$(echo "$topdata" | grep "mysql")
# 14625 mysql     20   0 1813624 516236   7796 S   0.0  3.2  25:57.82 mysqld
topelastic=$(echo "$topdata" | grep "elastic")
# 15063 elastic+  20   0 3741348 583332  18516 S   0.0  3.6  41:58.35 java
topmemcached=$(echo "$topdata" | grep "memcach")
# 14264 memcach+  20   0  403708  91804    776 S   0.0  0.6   0:43.09 memcached
topparsoid=$(echo "$topdata" | grep "parsoid")
# 21245 parsoid   20   0  698232  67836   7956 S   0.0  0.4   0:00.91 node
topapache=$(echo "$topdata" | grep "apache")
# 11925 apache    20   0  706516  77052  50568 S   0.0  0.5   0:06.94 httpd

# calculate total memory% used by all tasks of each application
mysqltotalmem=$(echo "$topdata" | grep "mysql" | awk '{ sum += $10 } END { print sum }')
elastictotalmem=$(echo "$topdata" | grep "elastic" | awk '{ sum += $10 } END { print sum }')
memcachedtotalmem=$(echo "$topdata" | grep "memcach" | awk '{ sum += $10 } END { print sum }')
parsoidtotalmem=$(echo "$topdata" | grep "parsoid" | awk '{ sum += $10 } END { print sum }')
apachetotalmem=$(echo "$topdata" | grep "apache" | awk '{ sum += $10 } END { print sum }')

# add data point to database
mysql -u root "--password=${mysql_root_pass}" -e"CREATE DATABASE IF NOT EXISTS server; use server; CREATE TABLE IF NOT EXISTS performance (datetime BIGINT, PRIMARY KEY (datetime), loadavg1 FLOAT(3), loadavg5 FLOAT(3), loadavg15 FLOAT(3), memorypercentused FLOAT(4), mysql FLOAT(4), es FLOAT(4), memcached FLOAT(4), parsoid FLOAT(4), apache FLOAT(4), jobs FLOAT(4)); INSERT INTO performance (datetime, loadavg1, loadavg5, loadavg15, memorypercentused, mysql, es, memcached, parsoid, apache, jobs) VALUES ('$datetime', $loadavg1, $loadavg5, $loadavg15, $memorypercentused, $mysqltotalmem, $elastictotalmem, $memcachedtotalmem, $parsoidtotalmem, $apachetotalmem, $jobs);"

jsontitle="Performance Report"

# at what level do we display amber color
warninglevel="50"
# at what level to we display red color
dangerlevel="75"
jsoncolor="good"
memoryusedtext="Mem: ${memorypercentused}%"
alerttext=""
if [ "$memorypercentusedrounded" -gt "$warninglevel" ]; then
    jsoncolor="warning"
    # bold the memory text
    memoryusedtext="*Mem: ${memorypercentused}%*"
fi
if [ "$memorypercentusedrounded" -gt "$dangerlevel" ]; then
    jsoncolor="danger"
    # alert the channel
    alerttext="<!everyone>"
fi

report="${topheader} ${memoryusedtext}\nMySQL: ${mysqltotalmem}% ES: ${elastictotalmem}% Memcached: ${memcachedtotalmem}% Parsoid: ${parsoidtotalmem}% Apache: ${apachetotalmem}%"

# Manually create json

json="{ 
      \"text\": \"${alerttext}\",
      \"attachments\": [
          {
              \"color\": \"${jsoncolor}\",
              \"fallback\": \"${memorypercentused}%\",
              \"text\": \"${report}\",
              \"mrkdwn_in\": [\"text\"]
          }
      ]
  }"

# Notify slack by default
notifyslack="true"

# When good, only notify slack at 8:00 AM and 4:00 PM
if [ "$jsoncolor" == "good" ]; then
  notifyslack="false"
  if [ $hour -eq 8 ] && [ $minute -eq 0 ]; then
    notifyslack="true"
  else
    if [ $hour -eq 16 ] && [ $minute -eq 0 ]; then
      notifyslack="true"
    fi
  fi
fi

# When warning, notify slack once per hour
if [ "$jsoncolor" == "warning" ] && [ $minute -ne 0 ]; then
  notifyslack="false"
fi

# Don't notify slack on weekends
# if [ $dayofweek -eq 0 ] || [ $dayofweek -eq 7 ]; then
#   notifyslack="false"
# fi

if [ $notifyslack == "true" ]; then
  curl -s -d "payload=$json" "$slackwebhook"
fi

