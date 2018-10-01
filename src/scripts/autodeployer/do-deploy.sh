#!/bin/sh
#
# Do deploy. Notify on success. Notify and retry on fail.
#
# To use this script, either pass in DEPLOY_TYPE, DEPLOY_ARGS, AND LOG_PREFIX,
# or set them ahead of time and `source` the script:
#
# 1. ./do-deploy.sh "Backup" "--skip-tags search-index" "test-deploy-"
#
# 2. DEPLOY_TYPE="Backup"
#    DEPLOY_ARGS="--skip-tags search-index"
#    LOG_PREFIX="test-deploy-"
#
# Args:
#    DEPLOY_TYPE: Just used in notifications for type of deploy, e.g. "Backup
#                 starting" or "Deploy starting" where "Backup" and "Deploy" are
#                 the DEPLOY_TYPE
#    DEPLOY_ARGS: Any arguments that are going to get added to the deploy
#                 command. So if you want to do:
#                     `meza deploy dev --tags mediawiki --skip-tags latest`
#                 The DEPLOY_ARGS would be "--tags mediawiki --skip-tags latest"
#    LOG_PREFIX:  Logs are written to /opt/data-meza/logs to a file ending in
#                 the date/time and ".log". Prefix it with something like
#                 "nightly-backup-" to make "nightly-backup-$DATETIME.log"

# Path to this file's directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


# Setting configuration for DEPLOY_TYPE, DEPLOY_ARGS, and LOG_PREFIX
#
#  If any of them is being set via script argument $1, $2, or $3, respectively,
#  then use that value. Otherwise check if they already have a value set earlier
#  within the enviroment, and set a default if not.
if [ ! -z "$1" ]; then
	DEPLOY_TYPE="$1"
elif [ -z "$DEPLOY_TYPE" ]; then
	DEPLOY_TYPE="Deploy"
fi

if [ ! -z "$2" ]; then
	DEPLOY_ARGS="$2"
elif [ -z "$DEPLOY_ARGS" ]; then
	DEPLOY_ARGS=""
fi

if [ ! -z "$3" ]; then
	LOG_PREFIX="$3"
elif [ -z "$LOG_PREFIX" ]; then
	LOG_PREFIX="deploy-"
fi

# Gets info about public config
source /opt/.deploy-meza/config.sh

# If SLACK_TOKEN not set from outside this script, grab from config.sh
# Same goes for other slack vars
if [ -z "$SLACK_TOKEN" ] && [ ! -z "$autodeployer_slack_token" ]; then
	SLACK_TOKEN="$autodeployer_slack_token"
fi
if [ -z "$SLACK_USERNAME" ] && [ ! -z "$autodeployer_slack_username" ]; then
	SLACK_USERNAME="$autodeployer_slack_username"
fi
if [ -z "$SLACK_CHANNEL" ] && [ ! -z "$autodeployer_slack_channel"  ]; then
	SLACK_CHANNEL="$autodeployer_slack_channel"
fi
if [ -z "$SLACK_ICON_URL" ] && [ ! -z "$autodeployer_slack_icon_url" ]; then
	SLACK_ICON_URL="$autodeployer_slack_icon_url"
fi


# If SLACK_TOKEN is set, send notification via slack. Else, use no-notify script
if [ ! -z "$SLACK_TOKEN" ]; then
	NOTIFY="$DIR/slack-notify.sh"
else
	NOTIFY="$DIR/no-notify.sh"
fi

source $NOTIFY "$DEPLOY_TYPE starting" "good"

# First try at deploy. Allow failures so we can capture them later
set +e
meza deploy "$m_environment" $DEPLOY_ARGS \
	> /opt/data-meza/logs/${LOG_PREFIX}`date "+%Y%m%d%H%M%S"`.log 2>&1

# If deploy success, notify. Else retry once.
if [ $? -eq 0 ]; then
	source $NOTIFY "$DEPLOY_TYPE complete" "good"
else
	source $NOTIFY "$DEPLOY_TYPE attempt failed. Retrying..." "warning"
	meza deploy "$m_environment" $DEPLOY_ARGS \
		> /opt/data-meza/logs/${LOG_PREFIX}`date "+%Y%m%d%H%M%S"`.log 2>&1

	if [ $? -eq 0 ]; then
		source $NOTIFY "$DEPLOY_TYPE complete" "good"
	else
		source $NOTIFY "$DEPLOY_TYPE failed" "danger"
	fi
fi




