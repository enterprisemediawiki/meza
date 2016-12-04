#!/bin/sh
#
# Setup synchronized time

# Enable time sync
# Ref: http://www.cyberciti.biz/faq/howto-install-ntp-to-synchronize-server-clock/
yum -y install ntp ntpdate ntp-doc # Install packages for time sync
chkconfig ntpd on # Activate service
ntpdate pool.ntp.org # Synchronize the system clock with 0.pool.ntp.org server
service ntpd start # Start service
# Optionally configure ntpd via /etc/ntp.conf
