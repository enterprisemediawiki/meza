#!/bin/bash
#
# Sets up $m_htdocs as a shared drive via samba
#

#
# For now this script is not called within the same shell as install.sh
# and thus it needs to know how to get to the config.sh script on it's own
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "/opt/.deploy-meza/config.sh"


echo "Installing samba"
yum -y install samba samba-client samba-common

chkconfig smb on
chkconfig nmb on

echo "Setting up iptables rules"
iptables -I INPUT 4 -m state --state NEW -m udp -p udp --dport 137 -j ACCEPT
iptables -I INPUT 5 -m state --state NEW -m udp -p udp --dport 138 -j ACCEPT
iptables -I INPUT 6 -m state --state NEW -m tcp -p tcp --dport 139 -j ACCEPT
service iptables save


cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
rm /etc/samba/smb.conf
touch /etc/samba/smb.conf


cat > /etc/samba/smb.conf <<- EOM
#======================= Global Settings =====================================
[global]
workgroup = WORKGROUP
security = share
map to guest = bad user
#============================ Share Definitions ==============================
[MyShare]
path = $m_htdocs
browsable =yes
writable = yes
guest ok = yes
read only = no
EOM

# restart samba services
service smb restart
service nmb restart


chmod -R 0777 $m_htdocs
