#!/bin/sh
#
# Send a message to Slack

slackwebhook="$1"
title="$2"
text="$3"

# Announce on Slack if a slack webhook provided
if [[ ! -z "$slackwebhook" ]]; then

	if [[ "$slackwebhook" = "n" ]]; then
		exit;
	fi

	if [[ ! -z "$title$text" ]]; then
		primary="$title"
		secondary="$text"
	elif [[ ! -z "$title" ]]; then
		primary="$title"
	elif [[ ! -z "$text" ]]; then
		primary="$text"
	else
		echo "no payload for webhook. exiting."
		exit 1;
	fi

	# removed from json: \"text\": \"Your meza installation is complete\"


	escapedPrimary=$(echo $title | sed 's/"/\"/g' | sed "s/'/\'/g" )



	if [[ ! -z "$secondary" ]]; then
		escapedSecondary=$(echo "$secondary" | sed 's/"/\"/g' | sed "s/'/\'/g" )
		fields="\"title\": \"$escapedPrimary\" ,\"value\": \"$escapedSecondary\""
	else
		fields="\"value\": \"$escapedPrimary\""
	fi

	json="{
	    \"attachments\": [
	        {
	            \"color\": \"#339966\",
	            \"fallback\": \"$escapedPrimary\",
	            \"fields\": [
	                {
	                    \"short\": false,
	                    $fields
	                }
	            ]
	        }
	    ]
	}"

	curl -s -d "payload=$json" "$slackwebhook"
	echo
	echo
	echo "Message sent to Slack webhook $slackwebhook"

fi