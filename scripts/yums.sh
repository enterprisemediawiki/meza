#!/bin/bash
#
# Setup everything that should be installed with yum.
#

print_title "Starting script yums.sh"

#
# Make sure deltarpm is installed
# CentOS 7 minimal install removed the deltarpm package, which handles the
# difference between versions of an RPM package. This means the whole new RPM
# does not have to be downloaded saving bandwidth. Do this before `yum update`
# so bandwidth savings are achieved immediately.
# Ref: http://danielgibbs.co.uk/2015/05/delta-rpms-disabled/
#
yum install -y deltarpm


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


# Get EPEL repository
source "$m_scripts/epel.sh"


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
    pam-devel \
    cifs-utils \
    httpd-devel \
    mod_ssl \
    mod_proxy_html \
    net-tools \
    vim \
    sendmail \
    sendmail-cf \
    m4 \
    expect \
    expectk \
    ghostscript
cmd_profile "END yum install dependency list"


#
# @todo: Should these re-run? network setup may not run on all machines
#
# chkconfig sshd on
# service sshd start

