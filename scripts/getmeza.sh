#!/bin/sh
#
# Bootstrap meza
#
#

if [ "$(whoami)" != "root" ]; then
	echo "Try running this script with sudo: \"sudo bash getmeza.sh\""
	exit 1
fi

yum install -y git

# Get meza
cd /opt
git clone https://github.com/enterprisemediawiki/meza.git

ln -s "/opt/meza/scripts/meza.sh" "/usr/bin/meza"

echo "meza command installed. Use it:"
echo "  sudo meza install monolith"
