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

if [ ! -d "/opt/meza" ]; then

	# Get meza
	cd /opt
	git clone https://github.com/enterprisemediawiki/meza.git

	# For now, use the dev branch
	cd /opt/meza
	git checkout dev

fi

if [ ! -f "/usr/bin/meza" ]; then
	ln -s "/opt/meza/scripts/meza.sh" "/usr/bin/meza"
fi

ret=false
getent passwd meza-ansible >/dev/null 2>&1 && ret=true

if $ret; then
    echo "meza-ansible already exists"
else
	echo
	echo "Add ansible master user"
	source "/opt/meza/scripts/ssh-users/setup-master-user.sh"
fi



echo "meza command installed. Use it:"
echo "  sudo meza install monolith"
