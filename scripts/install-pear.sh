#!/usr/bin/expect
#
# This script is using "expect" to script user inputs for PEAR
# since PEAR requires user prompts...there is no way to pass the
# information into the script another way (except expect!)
#
# This says when prompted for "1-11, 'all' or Enter to continue:"
# just send the carriage return (e.g. "enter to continue")

spawn wget -O /tmp/go-pear.phar http://pear.php.net/go-pear.phar
expect eof

spawn php /tmp/go-pear.phar

expect "1-12, 'all' or Enter to continue:"
send "\r"
expect eof

spawn rm /tmp/go-pear.phar
