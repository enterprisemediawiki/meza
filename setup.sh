#!/bin/bash
#
# Setup network configuration for a CentOS 6.6 virtual machine on VirtualBox
# Please see directions at https://github.com/enterprisemediawiki/meza1

# Get host-only IP address
while [ -z "$ipaddr" ]
do
echo -e "Enter your desired IP address (follow Meza1 VirtualBox Networking steps)"
read -e -i "192.168.56.56" ipaddr
done


#
# Load Meza1 repository
#
cd ~
mkdir sources
cd sources
wget https://github.com/enterprisemediawiki/Meza1/tarball/master -O meza1.tar.gz
mkdir meza1
tar xpvf meza1.tar.gz -C ./meza1 --strip-components 1

#
# Modify network scripts in /etc/sysconfig/network-scripts, 
# ifcfg-eth0 (for NAT network adapter) and ifcfg-eth1 (for host-only)
#
cd /etc/sysconfig/network-scripts

# modify ifcfg-eth0 (NAT)
sed -r -i 's/ONBOOT=no/ONBOOT=yes/g;' ./ifcfg-eth0
sed -r -i 's/NM_CONTROLLED=yes/NM_CONTROLLED=no/g;' ./ifcfg-eth0

# copy ifcfg-eth1  (host-only)
cp ~/sources/meza1/client_files/ifcfg-eth1 ./ifcfg-eth1

# modify IP address as required:
sed -r -i "s/IPADDR=192.168.56.56/IPADDR=$ipaddr/g;" ./ifcfg-eth1

# get eth1 HWADDR from ifconfig, insert int ifcfg-eth1
eth1_hwaddr="$(ifconfig eth1 | grep '[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}' -o -P)"
sed -r -i "s/HWADDR=.*$/HWADDR=$eth1_hwaddr/g;" ./ifcfg-eth1

# restart networking
service network restart

#
# Update everything managed by yum
#
#temporary-comment-out# yum -y update

#
# Get development tools
#
#perhaps-permenanent-comment-out# yum groupinstall -y development
#perhaps-permenanent-comment-out# yum install -y zlib-dev openssl-devel sqlite-devel bzip2-devel xz-libs

#
# Setup SSH
#
yum install -y openssh-server openssh-clients
chkconfig sshd on
service sshd start


echo -e "Network and SSH setup complete\n\n\n\n\n\nPlease login via SSH from your host machine, by doing:\n    ssh root@$ipaddr\n\nEnter your root password when prompted"

