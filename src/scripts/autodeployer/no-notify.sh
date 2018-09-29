#!/bin/sh
#
# Script used to handle when no notification system is set

echo -e "$(date "+\%Y-\%m-\%d"): No notification method set.\n  Color: $2\n  Message: $1" >> /opt/data-meza/logs/missing-notifier.log
