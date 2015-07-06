#!/bin/sh

#
# chkconfig: 35 99 99
# description: Node.js /etc/parsoid/api/server.js
#

. /etc/rc.d/init.d/functions

USER="parsoid"

DAEMON="/usr/local/bin/node"
ROOT_DIR="/etc/parsoid/api"

SERVER="$ROOT_DIR/server.js"
LOG_FILE="$ROOT_DIR/server.js.log"

LOCK_FILE="/var/lock/subsys/node-server"

do_start()
{
        if [ ! -f "$LOCK_FILE" ] ; then
                echo -n $"Starting $SERVER: "

                # Use "nohup" to prevent hang-up. Thanks to:
                # http://stackoverflow.com/questions/5818202/how-to-run-node-js-app-forever-when-console-is-closed
                runuser -l "$USER" -c "nohup $DAEMON $SERVER > $LOG_FILE &" && echo_success || echo_failure

                RETVAL=$?
                echo
                [ $RETVAL -eq 0 ] && touch $LOCK_FILE
        else
                echo "$SERVER is locked."
                RETVAL=1
        fi
}
do_stop()
{
        echo -n $"Stopping $SERVER: "
        pid=`ps -aefw | grep "$DAEMON $SERVER" | grep -v " grep " | awk '{print $2}'`
        kill -9 $pid > /dev/null 2>&1 && echo_success || echo_failure
        RETVAL=$?
        echo
        [ $RETVAL -eq 0 ] && rm -f $LOCK_FILE
}

case "$1" in
        start)
                do_start
                ;;
        stop)
                do_stop
                ;;
        restart)
                do_stop
                do_start
                ;;
        *)
                echo "Usage: $0 {start|stop|restart}"
                RETVAL=1
esac

exit $RETVAL