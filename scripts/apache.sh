#!/bin/bash
#
# Setup Apache webserver

print_title "Starting script apache.sh"

#
# Setup document root
#
chown -R apache:apache "$m_htdocs"
chmod -R 775 "$m_htdocs"


#
# Skip section (not titled) on httpd.conf "Supplemental configuration"
# Skip section titled "httpd-mpm.conf"
# Skip section titled "Vhosts for apache 2.4.12"
#
# @todo: figure out if this section is necessary For now skip section titled "httpd-security.conf"
#

# @todo: pick up from section "Modify config file"

#### NOT YET COMPLETE ####




cd /etc/httpd/conf


# rename default configuration file, get meza config file
mv httpd.conf httpd.default.conf
cp "$m_meza/scripts/config/httpd.conf" ./httpd.conf

# replace INSERT-DOMAIN-OR-IP with domain...or IP address
sed -r -i "s/INSERT-DOMAIN-OR-IP/$mw_api_domain/g;" ./httpd.conf



# create service script - THIS SHOULD BE DONE BY YUM NOW
# cd /etc/init.d
# cp "$m_meza/scripts/initd_httpd.sh" ./httpd
# chmod +x /etc/init.d/httpd


# create logrotate file
# THIS MAY BE DONE BY YUM, BUT SINCE THESE FILES ARE REFERENCED IN OUR
# CUSTOM httpd.conf WE SHOULD STICK WITH THIS FOR NOW. OUR CUSTOM httpd.conf
# MAY REQUIRE REVISION.
cd /etc/logrotate.d
cp "$m_meza/scripts/logrotated_httpd" ./httpd

cd "$m_htdocs"


# modify firewall rules
# CentOS 6 and earlier used iptables
# CentOS 7 (and presumably later) use firewalld
if grep -Fxq "VERSION_ID=\"7\"" /etc/os-release
then
	echo "Enterprise Linux version 7. Applying rule changes to firewalld"

	# Add access to https now
	# Add it as "permanent" so it get's done on future reboots
	firewall-cmd --zone=public --add-service=https
	firewall-cmd --zone=public --permanent --add-service=https

	# access via http allowed, but forwarded to https (see httpd.conf)
	firewall-cmd --zone=public --add-port=http/tcp
	firewall-cmd --zone=public --add-port=http/tcp --permanent

else
    echo "Enterprise Linux version 6. Applying rule changes to iptables"

	#
	# Configure IPTABLES to open port 80 (for Apache HTTP), or 443 for https
	# @todo: consider method to define entire iptables config:
	# http://blog.astaz3l.com/2015/03/06/secure-firewall-for-centos/
	#
	# iptables -I INPUT 5 -i eth1 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
	iptables -I INPUT 5 -i eth1 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
	service iptables save

fi


echo -e "\n\napache.sh complete."
# Apache httpd service not started yet. Started in php.sh
