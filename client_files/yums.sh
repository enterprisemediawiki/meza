#!/bin/bash
#
# Setup everything that should be installed with yum. 
#

#
# First check whether we're using 32 or 64 bit
#
cd ~/sources
if [ "$1" = "32" ]; then
    echo "Downloading RPM for 32-bit"
    wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.i686.rpm
elif [ "$1" = "64" ]; then
    echo "Downloading RPM for 64-bit"
    wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
else
    echo -e "No architecture specified. Execute this script like:\n  bash $0 32\n  -OR-\n  bash $0 64\nFor 32 or 64 bit architecture, respectively."
    exit 1
fi


#
# Update everything managed by yum
#
yum -y update


#
# Get development tools
#
yum groupinstall -y development


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
yum install -y \
	zlib-dev \
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
    libmcrypt-devel


#
# @todo: Should these re-run? network setup may not run on all machines
#
# chkconfig sshd on
# service sshd start

