#!/bin/sh

# Don't allow errors
set -e

echo "Start meza auto-deployer"
echo $(date "+%Y-%m-%d %H:%M:%S")

# must be root or sudoer
if [ "$(whoami)" != "root" ]; then
	echo "Try running this script with sudo: \"sudo bash unite-the-wikis.sh\""
	exit 1
fi

# Gets info about public config
source /opt/.deploy-meza/config.sh

GIT_FETCH="$m_scripts/git-fetch.sh"
SLACK_NOTIFY="$m_scripts/slack-notify.sh"

# Set Slack notify variables that are the same for all notifications
if [ ! -z "$autodeployer_slack_token" ];    then SLACK_TOKEN="$autodeployer_slack_token";       fi
if [ ! -z "$autodeployer_slack_username" ]; then SLACK_USERNAME="$autodeployer_slack_username"; fi
if [ ! -z "$autodeployer_slack_channel" ];  then SLACK_CHANNEL="$autodeployer_slack_channel";   fi
if [ ! -z "$autodeployer_slack_icon_url" ]; then SLACK_ICON_URL="$autodeployer_slack_icon_url"; fi

# FIXME: For now, don't touch secret config. At some point find a way to
#        configure it's repo and version.

if [ -z "$local_config_repo_repo" ]; then
	>&2 echo "Auto-deploy requires 'local_config_repo' var set in secret config"
	exit 1;
fi

if [ -z "$enforce_meza_version" ]; then
	>&2 echo "Auto-deploy requires 'enforce_meza_version' var set in public config"
	exit 1;
fi

# Set PUBLIC config version
#
# Could optionally set public config's repo in secret config, but since that is
# not done universally, not going to enforce it here. Just use whatever repo is
# currently being used as origin.
PUBLIC_CONFIG_DEST="/opt/conf-meza/public"
PUBLIC_CONFIG_REPO="$local_config_repo_repo"
PUBLIC_CONFIG_VERSION="$local_config_repo_version"
PUBLIC_CONFIG_CHANGE=$($GIT_FETCH "$PUBLIC_CONFIG_REPO" "$PUBLIC_CONFIG_DEST" "$PUBLIC_CONFIG_VERSION")

#
# Check if attempt to git-pull PUBLIC CONFIG failed
#
echo "$PUBLIC_CONFIG_CHANGE" | jq '.plays[0].tasks[0].hosts.localhost.failed' -e
if [ $? -eq 0 ]; then
	FAILED_MSG=$(echo "$PUBLIC_CONFIG_CHANGE" | jq .plays[0].tasks[0].hosts.localhost.msg -r)
	FULL_MSG="Updating public config failed with following message:\n  $FAILED_MSG"
	>&2 echo -e "$FULL_MSG"

	if [ ! -z "SLACK_TOKEN" ]; then
		SLACK_MESSAGE="$FULL_MSG"
		SLACK_COLOR="danger"
		source $SLACK_NOTIFY
	fi
	exit 1;
fi

#
# Check if changes were made to PUBLIC CONFIG
#
echo "$PUBLIC_CONFIG_CHANGE" | jq '.plays[0].tasks[0].hosts.localhost.changed' -e
if [ $? -eq 0 ]; then
	PUBLIC_CONFIG_BEFORE_HASH=$(echo "$PUBLIC_CONFIG_CHANGE" | jq '.plays[0].tasks[0].hosts.localhost.before' -r)
	PUBLIC_CONFIG_AFTER_HASH=$(echo "$PUBLIC_CONFIG_CHANGE" | jq '.plays[0].tasks[0].hosts.localhost.after' -r)
	PUBLIC_CONFIG_DIFF=$(cd "$DEST" && git diff "$PUBLIC_CONFIG_BEFORE_HASH..$PUBLIC_CONFIG_AFTER_HASH")
else
	PUBLIC_CONFIG_DIFF=""
fi

# Set MEZA version
MEZA_REPO="https://github.com/enterprisemediawiki/meza"
MEZA_DEST="/opt/meza"
MEZA_VERSION="$enforce_meza_version"
MEZA_CHANGE=$($GIT_FETCH "$MEZA_REPO" "$MEZA_DEST" "$MEZA_VERSION")

#
# Check if attempt to git-pull MEZA failed
#
echo "$MEZA_CHANGE" | jq '.plays[0].tasks[0].hosts.localhost.failed' -e
if [ $? -eq 0 ]; then
	FAILED_MSG=$(echo "$MEZA_CHANGE" | jq .plays[0].tasks[0].hosts.localhost.msg -r)
	FULL_MSG="Updating Meza failed with following message:\n  $FAILED_MSG"
	>&2 echo -e "$FULL_MSG"

	if [ ! -z "SLACK_TOKEN" ]; then
		SLACK_MESSAGE="$FULL_MSG"
		SLACK_COLOR="danger"
		source $SLACK_NOTIFY
	fi
	exit 1;
fi

#
# Check if changes were made to MEZA
#
echo "$MEZA_CHANGE" | jq '.plays[0].tasks[0].hosts.localhost.changed' -e
if [ $? -eq 0 ]; then
	MEZA_BEFORE_HASH=$(echo "$MEZA_CHANGE" | jq '.plays[0].tasks[0].hosts.localhost.before' -r)
	MEZA_AFTER_HASH=$(echo "$MEZA_CHANGE" | jq '.plays[0].tasks[0].hosts.localhost.after' -r)
else
	MEZA_AFTER_HASH=""
fi


#
# Neither Meza mor config changed? Exit.
#
if [ -z "$PUBLIC_CONFIG_DIFF$MEZA_AFTER_HASH" ]; then
	echo "Nothing to deploy"
	exit 0;
fi

#
# Notify if PUBLIC CONFIG changed
#
if [ ! -z "$PUBLIC_CONFIG_DIFF" ]; then

	MESSAGE=$(cat <<-END
		Public config changed versions:
		  FROM: $PUBLIC_CONFIG_BEFORE_HASH
		  TO:   $PUBLIC_CONFIG_AFTER_HASH

		Tracking version: $PUBLIC_CONFIG_VERSION

		Diff:

		$PUBLIC_CONFIG_DIFF
END
)

	echo -e "$MESSAGE"

	if [ ! -z "SLACK_TOKEN" ]; then
		SLACK_MESSAGE="$MESSAGE"
		SLACK_COLOR="good"
		source $SLACK_NOTIFY
	fi
fi

#
# Notify if MEZA changed
#
if [ ! -z "$MEZA_AFTER_HASH" ]; then

	MESSAGE=$(cat <<-END
		Meza application changed versions:
		  FROM: $MEZA_BEFORE_HASH
		  TO:   $MEZA_AFTER_HASH

		Tracking version: $MEZA_VERSION
END
)

	echo -e "$MESSAGE"

	if [ ! -z "SLACK_TOKEN" ]; then
		SLACK_MESSAGE="$MESSAGE"
		SLACK_COLOR="good"
		source $SLACK_NOTIFY
	fi
fi


#
# Do deploy
#
echo "Deploying"
DEPLOY_TYPE="Deploy"
DEPLOY_ARGS="" # autodeploy deploys everything
DEPLOY_LOG_PREFIX="deploy-after-config-change-"
source "$DIR/do-deploy.sh"
