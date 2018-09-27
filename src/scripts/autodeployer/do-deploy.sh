#!/bin/sh
#
# Do deploy. Notify on success. Notify and retry on fail.
#
# # DEPLOY_TYPE="Deploy" bash /opt/meza-backup-notifier/do-deploy.sh "" "deploy-after-config-change-"


# Path to this file's directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


NOTIFY="$DIR/slack-notify.sh"


###FIXME DESPLOY TYPE###
SLACK_MESSAGE="$DEPLOY_TYPE starting"
source $NOTIFY


if [ -z "$LOG_PREFIX" ]; then
	LOG_PREFIX="deploy-"
fi

# Make two attempts at deploy
meza deploy "$ENVIRONMENT" $DEPLOY_ARGS \
	> /opt/data-meza/logs/${LOG_PREFIX}`date "+%Y%m%d%H%M%S"`.log 2>&1 \
	&& source $NOTIFY success \
	|| ( \
		(source $NOTIFY retry && meza deploy "$ENVIRONMENT" $DEPLOY_ARGS) \
		> /opt/data-meza/logs/${LOG_PREFIX}`date "+%Y%m%d%H%M%S"`.log 2>&1 \
		&& source $NOTIFY success \
		|| source $NOTIFY fail
	)



auto_backup_from_source:
  my_env_name:
    cron_time: "0 2 * * *"
    yes_i_want_this_env_overwritten: True
  my_other_env:
    cron_time: "0 2 * * 6"
    yes_i_want_this_env_overwritten: True

autodeploy_times:
  my_env_name: "0 * * * 1-5"
  my_other_env: "30 * * * 1-5"
  my_prod_env: "0 19 * * 1-4"
