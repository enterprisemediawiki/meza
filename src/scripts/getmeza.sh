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

# Check distro and version to determine what needs to be installed
#
if [ -f /etc/redhat-release ]; then
	# This bit checks for the variant-release package and builds variables
	# appropriately
	#
	RH_VARIANTS="centos redhat rocky"

	for VARIANT in ${RH_VARIANTS}
	do
		version=$(rpm -q ${VARIANT}-release --queryformat "%{VERSION}" | grep -v not)
		if [ ! -z "${version}"  ]; then
			distro=${VARIANT}
			break
		fi
	done

# if Debian support still desired, add else condition here
fi 

# Install epel if not installed
if [ ! -f "/etc/yum.repos.d/epel.repo" ]; then

	case ${distro} in

		centos)
			yum install -y epel-release
			;;

		rocky)
			dnf install -y epel-release
			dnf config-manager --set-enabled powertools
			dnf module -y reset php
			dnf module -y enable php:7.4
			;;

		redhat)
			case ${version} in

				7.*)
					epel_repo_url="https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm"
					# epel_repo_gpg_key_url="/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7"
					rpm -Uvh $epel_repo_url
					yum install y git ansible libselinux-python
					;;

				8.*)
					echo "Enabling code-ready-builder and ansible repo for RHEL. This may take some time."
					subscription-manager repos --enable codeready-builder-for-rhel-8-$(arch)-rpms
					subscription-manager repos --enable ansible-2-for-rhel-8-$(arch)-rpms
					dnf install -y ${epel_repo_url}
					dnf module -y reset php
					dnf module -y enable php:7.4
					;;

				*)
					echo "RedHat version ${version} is not supported yet." && exit 187
					;;
			esac
			;;

		*)
			echo "Cannot determine operating system distro or version" && exit 187
			;;
	esac

fi

case ${distro} in

        centos)
                yum install -y git ansible libselinux-python
                ;;

        rocky)
		dnf install -y centos-release-ansible-29
		dnf install -y python36
		dnf install -y git ansible-2.9.27-1.el8.noarch
		dnf install -y python3-libselinux
		alternatives --set python /usr/bin/python3
                ;;

        redhat)
                case ${version} in

                        7.*)
                                yum install -y git ansible libselinux-python
                                ;;

                        8.*)
				dnf install -y python36
				dnf install -y git ansible
				dnf install -y python3-libselinux
				alternatives --set python /usr/bin/python3
                                ;;

                        *)
                                echo "RedHat version ${version} is not supported yet." && exit 188
                                ;;
                esac
                ;;

        *)
                echo "Cannot determine operating system distro or version" && exit 189
                ;;
esac


INSTALL_DIR=$(dirname $(dirname $(dirname ${SCRIPT_DIR})))

# if /opt/meza doesn't exist, clone into and use master branch (which is the
# default, but should we make this configurable?)
if [ ! -d "${INSTALL_DIR}/meza" ]; then
        git clone https://github.com/enterprisemediawiki/meza.git ${INSTALL_DIR}/meza --branch master
fi

# Make sure /opt/meza permissions are good in case git-cloned earlier
#  - Ensure users can read everything
#  - Ensure users can also execute directories
chmod a+r ${INSTALL_DIR}/meza -R
find ${INSTALL_DIR}/meza -type d -exec chmod 755 {} +

if [ ! -f "/usr/bin/meza" ]; then
	ln -s "${INSTALL_DIR}/meza/src/scripts/meza.py" "/usr/bin/meza"
fi

# Create .deploy-meza directory and very basic config.sh if they don't exist
# This is done to make the user setup script(s) work
mkdir -p ${INSTALL_DIR}/.deploy-meza
chmod 755 ${INSTALL_DIR}/.deploy-meza

if [ ! -f ${INSTALL_DIR}/.deploy-meza/config.sh ]; then
	echo "m_scripts='${INSTALL_DIR}/meza/src/scripts'; ansible_user='meza-ansible';" > ${INSTALL_DIR}/.deploy-meza/config.sh
fi

# make sure conf-meza exists and has good permissions
mkdir -p ${INSTALL_DIR}/conf-meza/secret
chmod 755 ${INSTALL_DIR}/conf-meza
chmod 775 ${INSTALL_DIR}/conf-meza/secret

# Required initially for creating lock files
mkdir -p ${INSTALL_DIR}/data-meza

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
		ls -la ${INSTALL_DIR}/conf-meza/users
		ls -la ${INSTALL_DIR}/conf-meza/users/meza-ansible
		ls -la ${INSTALL_DIR}/conf-meza/users/meza-ansible/.ssh
	else
		echo "meza-ansible home-dir in correct location"
	fi
else
	echo
	echo "Add ansible master user"
	source "${INSTALL_DIR}/meza/src/scripts/ssh-users/setup-master-user.sh"
fi

chown meza-ansible:wheel ${INSTALL_DIR}/conf-meza
chown meza-ansible:wheel ${INSTALL_DIR}/conf-meza/secret
chown meza-ansible:wheel ${INSTALL_DIR}/meza

# Don't require TTY or visible password for sudo. Ref #769
sed -r -i "s/^Defaults\\s+requiretty/#Defaults requiretty/g;" /etc/sudoers
sed -r -i "s/^Defaults\\s+\!visiblepw/#Defaults \\!visiblepw/g;" /etc/sudoers

echo "meza command installed. Use it:"
echo "  sudo meza deploy monolith"
