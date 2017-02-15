#!/bin/sh
#
# Bootstrap meza
#
#

if [ "$(whoami)" != "root" ]; then
	echo "Try running this script with sudo: \"sudo bash getmeza.sh\""
	exit 1
fi

yum install -y epel-release
yum install -y git ansible

# Get meza
cd /opt
git clone https://github.com/enterprisemediawiki/meza.git

# For now, use the dev branch
cd /opt/meza
git checkout dev

ln -s "/opt/meza/scripts/meza.sh" "/usr/bin/meza"

echo
echo "Add ansible master user"
source /opt/meza/scripts/ansible/setup-master-user.sh

echo "meza command installed. Use it:"
echo "  sudo meza install monolith"
