

#
# Modify network scripts in /etc/sysconfig/network-scripts, 
# ifcfg-eth0 (for NAT network adapter) and ifcfg-eth1 (for host-only)
#
cd /etc/sysconfig/network-scripts

# modify ifcfg-eth0 (NAT)
sed -r --in-place 's/ONBOOT=no/ONBOOT=yes/g;' ./ifcfg-eth0.txt
sed -r --in-place 's/NM_CONTROLLED=yes/NM_CONTROLLED=no/g;' ./ifcfg-eth0.txt

# get eth1 HWADDR
eth1_hwaddr="$(ifconfig eth1 | grep '[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}' -o -P)"

# modify ifcfg-eth1 (host-only)
cp ./ifcfg-eth0 ./ifcfg-eth1
sed -r --in-place "s/HWADDR=.*$/HWADDR=$eth1_hwaddr\nIPADDR=192.168.56.56\nNETMASK=255.255.255.0/g;" ./ifcfg-eth1
sed -r --in-place 's/BOOTPROTO=dhcp/BOOTPROTO=static/g;' ./test.txt

# restart networking
service network restart

#
# Update everything managed by yum
#
yum -y update

#
# Setup SSH
#
yum -y install openssh-server openssh-clients
chkconfig sshd on
service sshd start


#
# Configure IPTABLES
# @todo: consider method to define entire iptables config:
# http://blog.astaz3l.com/2015/03/06/secure-firewall-for-centos/
#
iptables -I INPUT 5 -i eth1 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
service iptables save

#
# @todo: setup EPEL, maybe
#

