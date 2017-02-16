#!/bin/bash
#
# Setup network configuration for a CentOS 6.6 virtual machine on VirtualBox
# Please see directions at https://github.com/enterprisemediawiki/meza

# Get host-only IP address
while [ -z "$ipaddr" ]; do
	echo -e "Enter your desired IP address (follow meza VirtualBox Networking steps)"
	read -e -i "192.168.56.56" ipaddr
done


#
# Modify network scripts in /etc/sysconfig/network-scripts,
# ifcfg-eth0 (for NAT network adapter) and ifcfg-eth1 (for host-only)
#
net_scripts="/etc/sysconfig/network-scripts"



# CentOS/RHEL Version?
if grep -Fxq "VERSION_ID=\"7\"" /etc/os-release
then
	echo "Enterprise Linux version 7."
	enterprise_linux_version="7"

	# CentOS 7 (and presumably later) use ifcfg-enp0s3 and ifcfg-enp0s8 files
	network_adapter1="ifcfg-enp0s3"
	network_adapter2="ifcfg-enp0s8"

else
	echo "Enterprise Linux version 6."
	enterprise_linux_version="6"

	# CentOS 6 (and presumably earlier) used ifcfg-eth0 and ifcfg-eth1 files
	network_adapter1="ifcfg-eth0"
	network_adapter2="ifcfg-eth1"
fi


# modify ifcfg-eth0 (NAT)
sed -r -i 's/ONBOOT=no/ONBOOT=yes/g;' "$net_scripts/$network_adapter1"
sed -r -i 's/NM_CONTROLLED=yes/NM_CONTROLLED=no/g;' "$net_scripts/$network_adapter1"


# note: prefix with \ removes root's alias in .bashrc to "cp -i" which forces cp
# to ask the user if they want to overwrite existing. We do want to overwrite.
curl -L "https://raw.githubusercontent.com/enterprisemediawiki/meza/master/config/template/$network_adapter2" > "$net_scripts/$network_adapter2"

# modify IP address as required:
sed -r -i "s/IPADDR=192.168.56.56/IPADDR=$ipaddr/g;" "./$network_adapter2"


# get eth1 HWADDR from ifconfig, insert into ifcfg-eth1
# Note: not required for CentOS 7 (ifcfg-enp0s8 does not have HWADDR)
if [ "$enterprise_linux_version" = "6" ]; then
	eth1_hwaddr="$(ifconfig eth1 | grep '[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}' -o -P)"
	sed -r -i "s/HWADDR=.*$/HWADDR=$eth1_hwaddr/g;" "$net_scripts/ifcfg-eth1"
fi


# restart networking
systemctl restart network


#
# Setup SSH
#
yum install -y openssh-server openssh-clients
systemctl enable sshd
systemctl start sshd


echo -e "Network and SSH setup complete\n\n\n\n\n\nPlease login via SSH from your host machine, by doing:\n	ssh root@$ipaddr\n\nEnter your root password when prompted"
