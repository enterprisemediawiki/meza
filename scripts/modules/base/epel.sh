#!/bin/sh
#
# Get EPEL


if [ "$m_architecture" = "32" ]; then
    echo "Downloading EPEL for 32-bit"
    epel_version="6/i386/epel-release-6-8.noarch.rpm"
elif [ "$m_architecture" = "64" ]; then

    if grep -Fxq "VERSION_ID=\"7\"" /etc/os-release
    then
        echo "Downloading EPEL for 64-bit Enterprise Linux v7"
        # First determine what the latest version of EPEL is. Meza kept breaking
        # each time EPEL got a new version. See #375 and #401
        epel_version=`curl -v --silent http://dl.fedoraproject.org/pub/epel/7/x86_64/e/ 2>&1 | grep -oh 'epel-release-7-[0-9]\+.noarch.rpm' | head -1`
        epel_version="7/x86_64/e/$epel_version"
    else
        echo "Downloading EPEL for 64-bit Enterprise Linux v6"
        epel_version="6/x86_64/epel-release-6-8.noarch.rpm"
    fi

else
    echo -e "There was an error in choosing architecture."
    exit 1
fi


# Get EPEL based on version chosen above
cd /tmp
curl -LO "http://dl.fedoraproject.org/pub/epel/$epel_version"

#
# Import EPEL repo so libmcrypt-devel can be installed (not in default repo)
#
rpm -ivh epel-release-*.noarch.rpm
