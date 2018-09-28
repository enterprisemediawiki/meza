#!/bin/sh
#
# Use Ansible's Slack module to send messages.
#
# Required variables
#   SLACK_TOKEN=""    # Exits script if you don't set this.
#
# Recommended variables
#   SLACK_MESSAGE=""  # Defaults to a pointless message. Set this one.
#   SLACK_COLOR=""    # Defaults to "good" which means "green". Also available
#                       are "warning" (orange) and "danger" (red) or using hex
#                       code (e.g. #439FE0 = light blue)
#
# Optional variables
#   SLACK_USERNAME="" # Will use your Slack token's default username by default
#   SLACK_CHANNEL=""  # Will use your Slack token's default channel by default
#   SLACK_ICON_URL="" # will use Meza logo by default

# Get directory to return to at end
CWD=$(pwd)

# change to directory holding appropriate ansible.cfg file for this operation
cd /opt/meza/config/core/adhoc



if [ -z "$SLACK_TOKEN" ]; then
	>&2 echo "You need to set a SLACK_TOKEN variable"
	exit 1;
fi

# if first param not empty, use it for SLACK_MESSAGE
if [ ! -z "$1" ]; then
	SLACK_MESSAGE="$1"
elif [ -z "$SLACK_MESSAGE" ]; then
	SLACK_MESSAGE="Empty message."
fi

# if second param not empty, use it for SLACK_COLOR
if [ ! -z "$2" ]; then
	SLACK_COLOR="$2"
elif [ -z "$SLACK_COLOR" ]; then
	SLACK_COLOR="good" # assume all is well
fi

if [ -z "$SLACK_CHANNEL" ]; then
	SLACK_CHANNEL_WITH_PARAM="channel='$SLACK_CHANNEL'"
else
	SLACK_CHANNEL_WITH_PARAM="" # use default for token
fi

if [ -z "$SLACK_USERNAME" ]; then
	SLACK_USERNAME_WITH_PARAM="username='$SLACK_USERNAME'"
else
	SLACK_USERNAME_WITH_PARAM="" # use default for token
fi

if [ -z "$SLACK_ICON_URL" ]; then
	SLACK_ICON_URL="https://github.com/enterprisemediawiki/meza/raw/master/src/roles/configure-wiki/files/logo.png"
fi


# Escape single quotes
SLACK_MESSAGE=$(echo "$SLACK_MESSAGE" | sed "s/'/\\\'/g")

# Turn on allowing failures
set +e

# for debug
echo "DEBUG OUTPUT OF SLACK NOTIFY COMMAND"
echo \
	"token='$SLACK_TOKEN' \
	$SLACK_CHANNEL_WITH_PARAM \
	msg='$SLACK_MESSAGE' \
	$SLACK_USERNAME_WITH_PARAM \
	icon_url=$SLACK_ICON_URL \
	link_names=1 \
	color=$SLACK_COLOR"

# Attempt to send message
ansible localhost -m slack -a \
	"token='$SLACK_TOKEN' \
	$SLACK_CHANNEL_WITH_PARAM \
	msg='$SLACK_MESSAGE' \
	$SLACK_USERNAME_WITH_PARAM \
	icon_url=$SLACK_ICON_URL \
	link_names=1 \
	color=$SLACK_COLOR"

# If message fails, send a generic message
if [ $? -eq 0 ]; then
	echo "Slack notify success"
else
	echo "Slack notify fail. Attempted message was:"
	echo "$SLACK_MESSAGE"
	SLACK_MESSAGE="Slack message failed. See logs for attempted message."
	ansible localhost -m slack -a \
		"token='$SLACK_TOKEN' \
		$SLACK_CHANNEL_WITH_PARAM \
		msg='$SLACK_MESSAGE' \
		$SLACK_USERNAME_WITH_PARAM \
		icon_url=$SLACK_ICON_URL \
		link_names=1 \
		color=$SLACK_COLOR"
fi

# Turn off allowing errors
set -e

cd "$CWD"
