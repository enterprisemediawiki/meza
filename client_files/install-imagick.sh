#!/bin/sh
#
# Install ImageMagick, Ghostscript and Xpdf


if [ "$(whoami)" != "root" ]; then
	echo "Try running this script with sudo: \"sudo bash install-imagick.sh\""
	exit 1
fi

#
# Install Ghostscript
#
yum -y install ghostscript


# Get ImageMagick
http://www.imagemagick.org/download/ImageMagick.tar.gz
tar xvzf ImageMagick.tar.gz

# Different versions may be downloaded, * to catch whatever version
cd ImageMagick*


./configure
make
make install


# According to http://www.imagemagick.org/script/install-source.php:
# "You may need to configure the dynamic linker run-time bindings"
ldconfig /usr/local/lib

# For testing should run: `make check`


cd ~

# Get xpdf-utils
wget ftp://ftp.foolabs.com/pub/xpdf/xpdfbin-linux-3.04.tar.gz
tar xvzf xpdfbin-linux-3.04.tar.gz

cd xpdfbin-linux-3.04

# Copy correct-architecture executables to /usr/local/bin
if [ $(uname -m | grep -c 64) -eq 1 ]; then
	# 64-bit
	cp -a ./bin64/. /usr/local/bin/
else
	# 32-bit
	cp -a ./bin32/. /usr/local/bin/
fi

# CentOS does not have /usr/local/man, but xpdf recommends the following
# copy man pages and sample
# note: sample is entirely commented out and requires modification
# cp ./doc/*.1 /usr/local/man/man1
# cp ./doc/*.5 /usr/local/man/man5
# cp ./doc/sample-xpdfrc /usr/local/etc/xpdfrc

