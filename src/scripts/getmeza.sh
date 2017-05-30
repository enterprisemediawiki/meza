#!/bin/sh
#
# Bootstrap meza
#
#

if [ "$(whoami)" != "root" ]; then
	echo "Try running this script with sudo: \"sudo bash getmeza.sh\""
	exit 1
fi

# Install epel if not installed
if [ ! -f "/etc/yum.repos.d/epel.repo" ]; then

	distro=$(cat /etc/redhat-release | grep -q "CentOS" && echo "CentOS" || echo "RedHat")

 	if [ "$distro" == "CentOS" ]; then
		yum install -y epel-release
	else # if RedHat
		epel_repo_url="https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm"
		# epel_repo_gpg_key_url="/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7"
		rpm -Uvh $epel_repo_url
	fi

fi

yum install -y git ansible libselinux-python

# if /opt/meza doesn't exist, clone into and use master branch (which is the
# default, but should we make this configurable?)
if [ ! -d "/opt/meza" ]; then
	git clone https://github.com/enterprisemediawiki/meza.git /opt/meza --branch master
fi

if [ ! -f "/usr/bin/meza" ]; then
	ln -s "/opt/meza/src/scripts/meza.py" "/usr/bin/meza"
fi

ret=false
getent passwd meza-ansible >/dev/null 2>&1 && ret=true

# Create .deploy-meza directory and very basic config.sh if they don't exist
# This is done to make the user setup script(s) work
if [ ! -d /opt/.deploy-meza ]; then
	mkdir /opt/.deploy-meza
fi
if [ ! -f /opt/.deploy-meza/config.sh ]; then
	echo "m_scripts='/opt/meza/src/scripts'; ansible_user='meza-ansible';" > /opt/.deploy-meza/config.sh
fi

if $ret; then
	echo "meza-ansible already exists"
	homedir=$( getent passwd "meza-ansible" | cut -d: -f6 )
	if [ "$homedir" == "/home/meza-ansible" ]; then
		echo "meza-ansible home directory not correct. moving."
		# if [ ! -d "/opt/conf-meza/users" ]; then
		# 	mkdir -p "/opt/conf-meza/users"
		# fi
		usermod -m -d "/opt/conf-meza/users/meza-ansible" "meza-ansible"
		ls -la /opt/conf-meza/users
		ls -la /opt/conf-meza/users/meza-ansible
		ls -la /opt/conf-meza/users/meza-ansible/.ssh
	else
		echo "meza-ansible home-dir in correct location"
	fi
else
	echo
	echo "Add ansible master user"
	source "/opt/meza/src/scripts/ssh-users/setup-master-user.sh"
fi

echo "meza command installed. Use it:"
echo "  sudo meza deploy monolith"
