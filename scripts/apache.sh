#!/bin/bash
#
# Setup Apache webserver

print_title "Starting script apache.sh"

# change to mezadownloads directory
cd ~/mezadownloads

#
# Download Apache httpd, Apache Portable Runtime (APR) and APR-util
# Note that these links may break when new versions are released
# See httpd [1] and APR [2] list of files to confirm versions before running.
#
# [1] http://www.us.apache.org/dist//httpd/
# [2] http://www.us.apache.org/dist//apr
#
httpd_version="2.4.16"
apr_version="1.5.2"
aprutil_version="1.5.4"
wget "http://archive.apache.org/dist/httpd/httpd-$httpd_version.tar.gz"
wget "http://archive.apache.org/dist/apr/apr-$apr_version.tar.gz"
wget "http://archive.apache.org/dist/apr/apr-util-$aprutil_version.tar.gz"


#
# Unpack and build Apache from source
#
tar -zxvf "httpd-$httpd_version.tar.gz"
tar -zxvf "apr-$apr_version.tar.gz"
tar -zxvf "apr-util-$aprutil_version.tar.gz"
cp -r "apr-$apr_version" "httpd-$httpd_version/srclib/apr"
cp -r "apr-util-$aprutil_version" "httpd-$httpd_version/srclib/apr-util"
mv "httpd-$httpd_version" "$m_meza/sources/httpd-$httpd_version"
cd "$m_meza/sources/httpd-$httpd_version"
cmd_profile "START apache build"
./configure --enable-ssl --enable-so --with-included-apr --with-mpm=event
make
make install
cmd_profile "END apache build"


#
# Apache user
#
groupadd www
useradd -G www -r apache
chown -R apache:www /usr/local/apache2


#
# Setup document root
#
chown -R apache:www "$m_htdocs"
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




cd /usr/local/apache2/conf

#
# Commenting out all modifications to httpd.conf. These should all be in
# "meza/scripts/config/httpd.conf" now. Anything
#
# update document root
# sed -r -i 's/\/usr\/local\/apache2\/htdocs/\/var\/www\/meza\/htdocs/g;' ./httpd.conf
# direct apache to execute PHP
# cat $m_meza/scripts/httpd-conf-additions.conf >> ./httpd.conf
# serve index.php as default file
# sed -r -i 's/DirectoryIndex\s*index.html/DirectoryIndex index.php index.html/g;' ./httpd.conf
# modify user that will handle web requests
# sed -r -i 's/User\s*daemon/User apache/g;' ./httpd.conf
# sed -r -i 's/Group\s*daemon/Group www/g;' ./httpd.conf


# rename default configuration file, get meza config file
mv httpd.conf httpd.default.conf
cp "$m_meza/scripts/config/httpd.conf" ./httpd.conf

# create service script
cd /etc/init.d
cp "$m_meza/scripts/initd_httpd.sh" ./httpd
chmod +x /etc/init.d/httpd

# create logrotate file
cd /etc/logrotate.d
cp "$m_meza/scripts/logrotated_httpd" ./httpd

cd "$m_htdocs"

#
# Defer starting httpd until PHP installed
#
# # Start webserver service
# chkconfig httpd on
# service httpd status
# service httpd restart


# modify firewall rules
# CentOS 6 and earlier used iptables
# CentOS 7 (and presumably later) use firewalld
if grep -Fxq "VERSION_ID=\"7\"" /etc/os-release
then
	echo "Enterprise Linux version 7. Applying rule changes to firewalld"

	# Add access to http now
	firewall-cmd --zone=public --add-port=http/tcp

	# Add it as "permanent" so it get's done on future reboots
	firewall-cmd --zone=public --add-port=http/tcp --permanent

else
    echo "Enterprise Linux version 6. Applying rule changes to iptables"

	#
	# Configure IPTABLES to open port 80 (for Apache HTTP)
	# @todo: consider method to define entire iptables config:
	# http://blog.astaz3l.com/2015/03/06/secure-firewall-for-centos/
	#
	iptables -I INPUT 5 -i eth1 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
	service iptables save

fi


echo -e "\n\nYour Apache 2.4 webserver has been setup.\n\nPlease use the web browser on your host computer to navigate to http://192.168.56.56 to test it out"

