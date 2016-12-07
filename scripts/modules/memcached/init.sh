#!/bin/sh
#
# Install memcached
# ref: http://www.if-not-true-then-false.com/2010/install-memcached-on-centos-fedora-red-hat/

echo "******* Copying memcached config file *******"
rm -f /etc/sysconfig/memcached
ln -s "$m_config/core/memcached" /etc/sysconfig/memcached

# Set Memcached to start automatically on boot
echo "******* Creating memcached service *******"
chkconfig memcached on
# Start Memcached
echo "******* Starting memcached service *******"
service memcached start

# For troubleshooting:
# Check memcached stats periodically between page loads to see if it is working
# ref: http://www.cyberciti.biz/faq/howto-install-memcached-under-rhel-fedora-centos/
# memcached-tool 127.0.0.1:11211 stats

# Note there are lines added to LocalSettings.php later for MW to use memcached
# but at this time memcached should work in general
