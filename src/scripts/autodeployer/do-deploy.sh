#!/bin/sh
#
# Do deploy. Notify on success. Notify and retry on fail.
#
# # DEPLOY_TYPE="Deploy" bash /opt/meza-backup-notifier/do-deploy.sh "" "deploy-after-config-change-"


# Path to this file's directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


SLACK_NOTIFY="$DIR/slack-notify.sh"


###FIXME DESPLOY TYPE###
source $SLACK_NOTIFY "$DEPLOY_TYPE starting" "good"


if [ -z "$LOG_PREFIX" ]; then
	LOG_PREFIX="deploy-"
fi


# First try at deploy. Allow failures so we can capture them later
set +e
meza deploy "$ENVIRONMENT" $DEPLOY_ARGS \
	> /opt/data-meza/logs/${LOG_PREFIX}`date "+%Y%m%d%H%M%S"`.log 2>&1

# If deploy success, notify. Else retry once.
if [ $? -eq 0 ]; then
	source $SLACK_NOTIFY "$DEPLOY_TYPE complete" "good"
else
	source $SLACK_NOTIFY "$DEPLOY_TYPE attempt failed. Retrying..." "warning"
	meza deploy "$ENVIRONMENT" $DEPLOY_ARGS \
		> /opt/data-meza/logs/${LOG_PREFIX}`date "+%Y%m%d%H%M%S"`.log 2>&1

	if [ $? -eq 0 ]; then
		source $SLACK_NOTIFY "$DEPLOY_TYPE complete" "good"
	else
		source $SLACK_NOTIFY "$DEPLOY_TYPE failed" "danger"
	fi
fi




