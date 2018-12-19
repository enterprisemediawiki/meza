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

# CentOS 7 (and presumably later) use ifcfg-enp0s3 and ifcfg-enp0s8 files
network_adapter1="ifcfg-enp0s3"
network_adapter2="ifcfg-enp0s8"

# modify first net interface (NAT)
sed -r -i 's/ONBOOT=no/ONBOOT=yes/g;' "$net_scripts/$network_adapter1"
sed -r -i 's/NM_CONTROLLED=yes/NM_CONTROLLED=no/g;' "$net_scripts/$network_adapter1"


# note: prefix with \ removes root's alias in .bashrc to "cp -i" which forces cp
# to ask the user if they want to overwrite existing. We do want to overwrite.
curl -L "https://raw.github.com/enterprisemediawiki/meza/master/config/template/$network_adapter2" > "$net_scripts/$network_adapter2"

# modify IP address as required:
sed -r -i "s/IPADDR=192.168.56.56/IPADDR=$ipaddr/g;" "$net_scripts/$network_adapter2"


# restart networking
systemctl restart network


#
# Setup SSH
#
yum install -y openssh-server openssh-clients
systemctl enable sshd
systemctl start sshd


echo -e "Network and SSH setup complete\n\n\n\n\n\nPlease login via SSH from your host machine, by doing:\n	ssh root@$ipaddr\n\nEnter your root password when prompted"
