#!/bin/sh
#
# Script used to handle when no notification system is set

echo -e "No notification method set.\nColor: $2\nMessage: $1" >> /opt/data-meza/logs/missing-notifier.log
