#!/bin/sh
#
# Install ImageMagick, Ghostscript and Xpdf

print_title "Starting script imagemagick.sh"


if [ "$(whoami)" != "root" ]; then
	echo "Try running this script with sudo: \"sudo bash imagemagick.sh\""
	exit 1
fi


# Get ImageMagick
echo "Downloading and ImageMagick"
cd ~/mezadownloads
wget http://www.imagemagick.org/download/ImageMagick.tar.gz
tar xvzf ImageMagick.tar.gz

# Different versions may be downloaded, * to catch whatever version
mv ImageMagick-* "$m_meza/sources/ImageMagick"
cd "$m_meza/sources/ImageMagick"

cmd_profile "START build ImageMagick"
echo "Configure ImageMagick"
./configure
echo "Make ImageMagick"
make
echo "Make install ImageMagick"
make install
cmd_profile "END build ImageMagick"


# According to http://www.imagemagick.org/script/install-source.php:
# "You may need to configure the dynamic linker run-time bindings"
echo "Configure dynamic linker"
ldconfig /usr/local/lib

# For testing should run: `make check`


# Get xpdf-utils
echo "Download xpdf-utils"
cd ~/mezadownloads
wget http://mirror.unl.edu/ctan/support/xpdf/xpdfbin-linux-3.04.tar.gz
tar xvzf xpdfbin-linux-3.04.tar.gz

cd xpdfbin-linux-3.04

# Copy correct-architecture executables to /usr/local/bin
if [ $(uname -m | grep -c 64) -eq 1 ]; then
	echo "Move 64-bit executables to /usr/local/bin"
	cp -a ./bin64/. /usr/local/bin/
else
	echo "Move 32-bit executables to /usr/local/bin"
	cp -a ./bin32/. /usr/local/bin/
fi

# CentOS does not have /usr/local/man, but xpdf recommends the following
# copy man pages and sample
# note: sample is entirely commented out and requires modification
# cp ./doc/*.1 /usr/local/man/man1
# cp ./doc/*.5 /usr/local/man/man5
# cp ./doc/sample-xpdfrc /usr/local/etc/xpdfrc

