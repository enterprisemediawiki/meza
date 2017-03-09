#!/bin/bash
#
# Setup Apache webserver

#
# Setup document root
#
chown -R apache:apache "$m_htdocs"
chmod -R 775 "$m_htdocs"

# rename default configuration file, get meza config file
cd "$m_apache/conf"
mv httpd.conf httpd.default.conf
ln -s "$m_config/core/httpd.conf" "$m_apache/conf/httpd.conf"

# replace INSERT-DOMAIN-OR-IP with domain...or IP address
sed -r -i "s/INSERT-DOMAIN-OR-IP/$mw_api_domain/g;" "$m_config/core/httpd.conf"

# create logrotate file
ln -s " $m_config/core/logrotated_httpd" /etc/logrotate.d/httpd


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

	# access to 8008 for reverse proxy for elasticsearch
	firewall-cmd --zone=public --add-port=8008/tcp
	firewall-cmd --zone=public --add-port=8008/tcp --permanent


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

#
# Below attempts to make SELinux play nice with services. This works for
# elasticsearch, but parsoid runs sooooo sloooow. Disabling SELinux.
#

# enable SELinux management commands
# yum -y install setroubleshoot-server selinux-policy-devel

# Make SELinux respect parsoid
# sudo semanage port -a -t http_port_t -p tcp 8000

# make SELinux respect elasticsearc
# sudo semanage port -a -t http_port_t -p tcp 9200
# sudo semanage port -a -t http_port_t -p tcp 9300


# Generate private key and self-signed certificate
# These should be replaced by appropriate files later
openssl_self_sign_subject="/C=US/ST=TX/L=Houston/O=EnterpriseMediaWiki/CN=enterprisemediawiki.org"
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
    -subj "$openssl_self_sign_subject" \
    -keyout /etc/pki/tls/private/meza.key -out /etc/pki/tls/certs/meza.crt


# Make directory and file that will eventually hold info about CA Certificate location
local_httpd_conf="/opt/meza/config/local/httpd"
mkdir "$local_httpd_conf"
echo "# Use 443.conf to add directives to HTTPS connections" > "$local_httpd_conf/443.conf"
echo "# See /opt/meza/config/core/httpd.conf"               >> "$local_httpd_conf/443.conf"


echo
echo "apache.sh complete. httpd service not started yet (will start in php.sh)"
