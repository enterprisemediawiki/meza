#!/bin/sh
#
# Bootstrap meza
#
#

if [ "$(whoami)" != "root" ]; then
	echo "Try running this script with sudo: \"sudo bash getmeza.sh\""
	exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

for ARG in "$@"; do
	if [ "${ARG}" = "--skip-conn-check" ]; then
		SKIP_CONNECTION_CHECK="true"
	fi
done

checkInternetConnection() {
    declare -i pingRetries=100
    declare -i sleepDuration=3
    declare -i minutes=$(($pingRetries * $sleepDuration / 60))

    while [[ $pingRetries -gt 0 ]] && ! ping -c 1 -W 1 mirrorlist.centos.org >/dev/null 2>&1; do
        echo "Could not connect to mirrorlist.centos.org. Internet connection might be down. Retrying (#$pingRetries) in $sleepDuration seconds..."
        ((pingRetries -= 1))
        sleep $sleepDuration
    done

    if [[ ! $pingRetries -gt 0 ]]; then
        echo "Meza has been trying to install but hasn't found an internet connection for $minutes minutes. Verify internet connectivity and try again."
        exit 1
    fi
}

if [ ! -z "${SKIP_CONNECTION_CHECK}" ]; then
	echo "Skipping connection check"
else
	checkInternetConnection
fi

# If you don't do this in a restrictive system (umask 077), it becomes
# difficult to manage all permissions, AND you constantly have to fix all git
# clones and checkouts.
umask 002


if [ -f "/etc/redhat-release" ]; then
	distro_major="redhat"
else
	distro_major="debian"
fi


# Install epel if not installed
if [ $distro_major = "redhat" ] && [ ! -f "/etc/yum.repos.d/epel.repo" ]; then

	distro=$(cat /etc/redhat-release | grep -q "CentOS" && echo "CentOS" || echo "RedHat")

 	if [ "$distro" == "CentOS" ]; then
		yum install -y epel-release
	else # if RedHat
		epel_repo_url="https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm"
		# epel_repo_gpg_key_url="/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7"
		rpm -Uvh $epel_repo_url
	fi

fi

if [ $distro_major = "redhat" ]; then
	yum install -y git ansible libselinux-python
else

	if grep -q 'wheel' '/etc/group'; then
		echo "group 'wheel' exists"
	else
		echo "group 'wheel' does not exist. creating."
		groupadd wheel

		# FIXME: any reason to add this:
		# https://wiki.debian.org/WHEEL/PAM
	fi

	# apt-get install -y dirmngr
	# echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" >> /etc/apt/sources.list

	# apt-get install -y software-properties-common
	# apt-add-repository -y ppa:ansible/ansible
	# apt-get -y update
	# apt-get install -y ansible
	# apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
	# apt-get update

	apt-get install -y git python-yaml

	# Ansible in Debian package is 2.2
	# apt-get install -y ansible

	apt-get install -y python-setuptools
	easy_install pip
	pip install ansible
	# source ~/.bashrc

fi

# SCRIPT_DIR typically /opt/meza/src/scripts, INSTALL_DIR typically /opt
INSTALL_DIR=$(dirname $(dirname $(dirname ${SCRIPT_DIR})))

# Make sure /opt/meza permissions are good in case git-cloned earlier
#  - Ensure users can read everything
#  - Ensure users can also execute directories
chmod a+r "${INSTALL_DIR}/meza" -R
find "${INSTALL_DIR}/meza" -type d -exec chmod 755 {} +

if [ ! -f "/usr/bin/meza" ]; then
	ln -s "${INSTALL_DIR}/meza/src/scripts/meza.py" "/usr/bin/meza"
fi

# Create .deploy-meza directory and very basic config.sh if they don't exist
# This is done to make the user setup script(s) work
mkdir -p "${INSTALL_DIR}/.deploy-meza"
chmod 755 "${INSTALL_DIR}/.deploy-meza"

if [ ! -f "${INSTALL_DIR}/.deploy-meza/config.sh" ]; then
	echo "m_scripts='${INSTALL_DIR}/meza/src/scripts'; ansible_user='meza-ansible';" > "${INSTALL_DIR}/.deploy-meza/config.sh"
fi

# make sure conf-meza exists and has good permissions
mkdir -p "${INSTALL_DIR}/conf-meza/secret"
chmod 755 "${INSTALL_DIR}/conf-meza"
chmod 775 "${INSTALL_DIR}/conf-meza/secret"

# Required initially for creating lock files
mkdir -p "${INSTALL_DIR}/data-meza"

# If user meza-ansible already exists, make sure home directory is correct
# (update from old meza versions)
ret=false
getent passwd meza-ansible >/dev/null 2>&1 && ret=true
if $ret; then
	echo "meza-ansible already exists"
	homedir=$( getent passwd "meza-ansible" | cut -d: -f6 )
	if [ "$homedir" == "/home/meza-ansible" ]; then
		echo "meza-ansible home directory not correct. moving."
		mkdir -p "${INSTALL_DIR}/conf-meza/users"
		usermod -m -d "${INSTALL_DIR}/conf-meza/users/meza-ansible" "meza-ansible"
		ls -la "${INSTALL_DIR}/conf-meza/users"
		ls -la "${INSTALL_DIR}/conf-meza/users/meza-ansible"
		ls -la "${INSTALL_DIR}/conf-meza/users/meza-ansible/.ssh"
	else
		echo "meza-ansible home-dir in correct location"
	fi
else
	echo
	echo "Add ansible master user"
	source "${INSTALL_DIR}/meza/src/scripts/ssh-users/setup-master-user.sh"
fi

chown meza-ansible:wheel "${INSTALL_DIR}/conf-meza"
chown meza-ansible:wheel "${INSTALL_DIR}/conf-meza/secret"
chown meza-ansible:wheel "${INSTALL_DIR}/meza"

# Don't require TTY or visible password for sudo. Ref #769
sed -r -i "s/^Defaults\\s+requiretty/#Defaults requiretty/g;" /etc/sudoers
sed -r -i "s/^Defaults\\s+\!visiblepw/#Defaults \\!visiblepw/g;" /etc/sudoers

echo "meza command installed. Use it:"
echo "  sudo meza deploy monolith"
