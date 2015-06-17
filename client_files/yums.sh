#!/bin/bash
#
# Setup everything that should be installed with yum. 
#

#
# Update everything managed by yum
#
yum -y update


#
# Get development tools
#
yum groupinstall -y development

#
# Install all packages you'll need thoughout LAMP setup
# Some may be included in groupinstall above, and will be ignored, but better
# safe than sorry--attempt to install them now anyway.
#
yum install -y \

	# generically good things to have
	zlib-dev \
	sqlite-devel \
	bzip2-devel \
	xz-libs \
	openssh-server \
	openssh-clients \
	perl \

	# Apache requirements
	wget \
	gcc \
	pcre-devel \
	openssl-devel \

	# PHP requirements
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
    libtidy-devel


#
# @todo: Should these re-run? network setup may not run on all machines
#
# chkconfig sshd on
# service sshd start

