#!/bin/sh
#
# Setup and execute a remote backup test


source "/opt/meza/config/core/config.sh"
source "$m_scripts/shell-functions/base.sh"
rootCheck # function that does the checks for root/sudo

# Get test setup file for this test
test_name="remote-backup"


# Copy test's import-config.sh into config/local for use by backup and import scripts
# If import-config.sh already exists, remove it.
if [ -f "$m_config/local/import-config.sh" ]; then
	rm "$m_config/local/import-config.sh"
fi
cp "$m_test/$test_name/import-config.sh" "$m_config/local/import-config.sh"


# Set source server by passing as first arg to this script, else exit
if [ ! -z "$1" ]; then
	source_server="$1"
else
	echo
	echo "Please include the source server IP address or hostname, e.g."
	echo "sudo bash run-test.sh 192.168.56.56 <mysql-root-pass> <remote-mysql-root-pass>"
	echo " - or -"
	echo "sudo bash run-test.sh example.com <mysql-root-pass> <remote-mysql-root-pass>"
	exit 1
fi

# Set local MySQL root password as second arg, else exit
if [ ! -z "$2" ]; then
	mysql_root_pass="$2"
else
	echo
	echo "Please include the mysql root password for this server, e.g."
	echo "sudo bash run-test.sh <host> mypassword <remote-mysql-root-pass>"
	exit 1
fi

# Set remote server MySQL root password as third art, else exit
if [ ! -z "$3" ]; then
	remote_mysql_root_pass="$3"
else
	echo
	echo "Please include the mysql root password for the source server, e.g."
	echo "sudo bash run-test.sh <host> <mysql-root-pass> mypassword"
	exit 1
fi


# Remove TBDs in import-config.sh
sed -r -i "s/remote_domain=TBD/remote_domain=$source_server/g;" "$m_config/local/import-config.sh"
sed -r -i "s/mysql_root_pass=TBD/mysql_root_pass=$mysql_root_pass/g;" "$m_config/local/import-config.sh"
sed -r -i "s/remote_db_password=TBD/remote_db_password=$remote_mysql_root_pass/g;" "$m_config/local/import-config.sh"


# source the import-config.sh for use by THIS script (it'll also be used by
# backup and import scripts)
source "$m_config/local/import-config.sh"


# Create user
source "$m_scripts/shell-functions/add-user.sh"
add_ssh_user "$backup_user_name"

# generate SSH key
ssh-keygen -t rsa -N "" -f "/home/$backup_user_name/.ssh/id_rsa"
# --> Put SSH key on source server
# StrictHostKeyChecking=no == don't check if server fingerprint is okay
scp -oStrictHostKeyChecking=no "/home/$backup_user_name/.ssh/id_rsa.pub" "$source_root_user@$source_server:$temp_pub_key_path"

# Take $backup_user_name's private key and let root use it
mkdir -p "/root/.ssh"
chmod 700 "/root/.ssh"
cp "/home/$backup_user_name/.ssh/id_rsa" "/root/.ssh/id_rsa"

# Make a logs dir. Comes from import-config.sh
if [ ! -d "$backup_logpath" ]; then
	mkdir "$backup_logpath"
fi
# chmod 744 "$backup_logpath" # FIXME: Why?

# SSH into source server,
ssh -oStrictHostKeyChecking=no -q "$source_root_user@$source_server" "bash $m_test/$test_name/source-server-setup.sh"

# These should be modified in Git to make them 744 by default
# FIXME: Set permissions via Git
# chmod 744 "$m_scripts/backup-remote-wikis.sh"
# chmod 744 "$m_scripts/import-wikis.sh"

# Run backup and import
bash "$m_scripts/backup-remote-wikis.sh"
bash "$m_scripts/import-wikis.sh"

# Need to update extensions in case individual wikis have different reqs
# FIXME: So should import-wikis.sh update extensions for each wiki imported? An
# imported wiki won't function if additional extensions it requires aren't installed.
bash "$m_scripts/updateExtensions.sh"

# FIXME: why do we need this?
# service httpd restart

echo "DONE"
