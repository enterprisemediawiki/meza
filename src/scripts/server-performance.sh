#!/bin/bash
#
# server-performance.sh
#
# Use `top` to get performance stats, then record stats in DB and send Slack
# notification


# If /usr/local/bin is not in PATH then add it
# Ref enterprisemediawiki/meza#68 "Run install.sh with non-root user"
if [[ $PATH != *"/usr/local/bin"* ]]; then
	PATH="/usr/local/bin:$PATH"
fi

source "/opt/.deploy-meza/config.sh"

# TEMPORARY method of recording slack webhooks. Should be in
# secret/secret.yml and then written to a dynamic shell script
# file.
logging_config="/opt/.deploy-meza/logging.sh"
if [ -f "$logging_config" ]; then
	source "$logging_config"
fi

if [ -z "$slack_webhook_token_server_performance" ]; then
	slack_token=""
else
	slack_token="$slack_webhook_token_server_performance"
fi

# If no channel in config, don't specify one in ansible-slack call, thus using
# webhook default channel
if [ -z "$slack_channel_server_performance" ]; then
	slack_channel=""
else
	slack_channel="channel=#$slack_channel_server_performance"
fi

# Slack username
if [ ! -z "$slack_username_server_performance" ]; then
	slack_username="$slack_username_server_performance"
else
	slack_username="Meza performance monitor"
fi

# get all the dataz
datetime=$(date "+%Y%m%d%H%M%S")
dayofweek=$(date +%u)
hour=$(date +%H)
minute=$(date +%M)
topdata=$(top -b -n 1)

jobs=0

cd /opt/htdocs/wikis
for d in */
do
	wiki_id=${d%/}
	moreJobs=$(WIKI=$wiki_id php /opt/htdocs/mediawiki/maintenance/showJobs.php)
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


insert_sql=`cat <<EOF
	INSERT INTO meza_server_log.performance
	(
		datetime,
		loadavg1,
		loadavg5,
		loadavg15,
		memorypercentused,
		mysql,
		es,
		memcached,
		parsoid,
		apache,
		jobs
	)
	VALUES
	(
		'$datetime',
		$loadavg1,
		$loadavg5,
		$loadavg15,
		$memorypercentused,
		$mysqltotalmem,
		$elastictotalmem,
		$memcachedtotalmem,
		$parsoidtotalmem,
		$apachetotalmem,
		$jobs
	);
EOF`


# add data point to database
sudo -u root mysql -e"$insert_sql"


jsontitle="Performance Report"

# at what level do we display amber color
warninglevel="50"
# at what level to we display red color
dangerlevel="75"
slack_msg_color="good"
memoryusedtext="Mem: ${memorypercentused}%"
alerttext=""
if [ "$memorypercentusedrounded" -gt "$warninglevel" ]; then
	slack_msg_color="warning"
	# bold the memory text
	memoryusedtext="*Mem: ${memorypercentused}%*"
fi
if [ "$memorypercentusedrounded" -gt "$dangerlevel" ]; then
	slack_msg_color="danger"
	# alert the channel
	alerttext="<!everyone>"
fi

report="${topheader} ${memoryusedtext}\nMySQL: ${mysqltotalmem}% ES: ${elastictotalmem}% Memcached: ${memcachedtotalmem}% Parsoid: ${parsoidtotalmem}% Apache: ${apachetotalmem}%"


# Notify slack by default
notifyslack="true"

# When good, only notify slack at 8:00 AM and 4:00 PM
if [ "$slack_msg_color" == "good" ]; then
	notifyslack="false"
	if [ $hour -eq 8 ] && [ $minute -eq 0 ]; then
		notifyslack="true"
	elif [ $hour -eq 16 ] && [ $minute -eq 0 ]; then
		notifyslack="true"
	fi
fi

# When warning, notify slack once per hour
if [ "$slack_msg_color" == "warning" ] && [ $minute -ne 0 ]; then
	notifyslack="false"
fi

# Don't notify slack on weekends
# if [ $dayofweek -eq 0 ] || [ $dayofweek -eq 7 ]; then
#   notifyslack="false"
# fi

if [ $notifyslack == "true" ] && [ $slack_token ]; then

	ansible localhost -m slack -a \
		"token=$slack_token $slack_channel \
		msg='$report' \
		username='$slack_username' \
		icon_url=https://github.com/enterprisemediawiki/meza/raw/master/src/roles/configure-wiki/files/logo.png \
		link_names=1 \
		color=$slack_msg_color"

fi



