#!/bin/bash
#
# Setup PHP

print_title "Starting script php.sh"



cd "$m_meza/sources/meza-packages/RPMs"
yum install -y ./php_*


#
# Initiate php.ini
#
ln -s "$m_config/core/php.ini" /usr/local/php/lib/php.ini


#
# Start webserver service
#
chkconfig httpd on
service httpd status
service httpd restart

# Install PEAR and PEAR Mail
chmod 744 "$m_meza/scripts/install-pear.sh"
"$m_meza/scripts/install-pear.sh"
/usr/local/php/bin/pear install --alldeps Mail

echo -e "\n\nPHP has been setup.\n\nPlease use the web browser on your host computer to navigate to http://192.168.56.56/info.php to verify php is being executed."
