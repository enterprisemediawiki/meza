#!/bin/sh
#
# Do deploy. Notify on success. Notify and retry on fail.
#
# # DEPLOY_TYPE="Deploy" bash /opt/meza-backup-notifier/do-deploy.sh "" "deploy-after-config-change-"


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
if [ -z "$SLACK_TOKEN" ]; then
	SLACK_TOKEN="$autodeployer_slack_token"
fi

# If SLACK_TOKEN is set, send notification via slack. Else, use no-notify script
if [ -z "$SLACK_TOKEN" ]; then
	NOTIFY="$DIR/slack-notify.sh"
else
	NOTIFY="$DIR/no-notify.sh"
fi

source $NOTIFY "$DEPLOY_TYPE starting" "good"

# First try at deploy. Allow failures so we can capture them later
set +e
meza deploy "$ENVIRONMENT" $DEPLOY_ARGS \
	> /opt/data-meza/logs/${LOG_PREFIX}`date "+%Y%m%d%H%M%S"`.log 2>&1

# If deploy success, notify. Else retry once.
if [ $? -eq 0 ]; then
	source $NOTIFY "$DEPLOY_TYPE complete" "good"
else
	source $NOTIFY "$DEPLOY_TYPE attempt failed. Retrying..." "warning"
	meza deploy "$ENVIRONMENT" $DEPLOY_ARGS \
		> /opt/data-meza/logs/${LOG_PREFIX}`date "+%Y%m%d%H%M%S"`.log 2>&1

	if [ $? -eq 0 ]; then
		source $NOTIFY "$DEPLOY_TYPE complete" "good"
	else
		source $NOTIFY "$DEPLOY_TYPE failed" "danger"
	fi
fi




