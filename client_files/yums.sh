#!/bin/bash
#
# Setup everything that should be installed with yum. 
#

bash printTitle.sh "Begin $0"

cd ~/sources

#
# Set architecture to 32 or 64 (bit)
#
if [ $(uname -m | grep -c 64) -eq 1 ]; then
architecture=64
else
architecture=32
fi


if [ "$architecture" = "32" ]; then
    echo "Downloading RPM for 32-bit"
    wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.i686.rpm
elif [ "$architecture" = "64" ]; then
    echo "Downloading RPM for 64-bit"
    wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
else
    echo -e "There was an error in choosing architecture."
    exit 1
fi


#
# Update everything managed by yum
#
cmd_profile "START yum update"
yum -y update
cmd_profile "END yum update"

#
# Do any RedHat or CentOS specific items
#
if [ -f /etc/centos-release ]; then
	# do centos-specific stuff
    echo "No special actions for CentOS" # need to have something in this block or error occurs
else
	# do redhat-specific stuff
	# thanks to https://bluehatrecord.wordpress.com for teaching me this
	# https://bluehatrecord.wordpress.com/2014/10/13/installing-r-on-red-hat-enterprise-linux-6-5/

	# Enable "optional RPMs" repo to be able to get: libc-client-devel.i686,
	# libc-client-devel, libicu-devel, t1lib-devel, aspell-devel, libvpx-devel
	# and libtidy-devel 
    echo "Enable \"Optional RPMs\" repo for RedHat"
	subscription-manager repos --enable=rhel-6-server-optional-rpms
fi


#
# Get development tools
#
cmd_profile "START yum groupinstall development"
yum groupinstall -y development
cmd_profile "END yum groupinstall development"

#
# Import RPM repo so libmcrypt-devel can be installed (not in default repo)
#
rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
rpm -K rpmforge-release-0.5.3-1.el6.rf.*.rpm # Verifies the package
rpm -i rpmforge-release-0.5.3-1.el6.rf.*.rpm


#
# Install all packages you'll need thoughout LAMP setup
# Some may be included in groupinstall above, and will be ignored, but better
# safe than sorry--attempt to install them now anyway.
#
cmd_profile "START yum install dependency list"
yum install -y \
    zlib-devel \
    sqlite-devel \
    bzip2-devel \
    xz-libs \
    openssh-server \
    openssh-clients \
    perl \
    wget \
    gcc \
    pcre-devel \
    openssl-devel \
    curl-devel \
    libc-client-devel.i686 \
    libc-client-devel \
    libxml2-devel \
    libXpm-devel \
    gmp-devel \
    libicu-devel \
    t1lib-devel \
    aspell-devel \
    libcurl-devel \
    libjpeg-devel \
    libvpx-devel \
    libpng-devel \
    freetype-devel \
    readline-devel \
    libtidy-devel \
    libmcrypt-devel \
    pam-devel
cmd_profile "END yum install dependency list"


#
# @todo: Should these re-run? network setup may not run on all machines
#
# chkconfig sshd on
# service sshd start

