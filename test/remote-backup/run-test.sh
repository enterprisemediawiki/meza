#!/bin/sh
#
# Setup and execute a remote backup test


source "/opt/meza/config/core/config.sh"
source "$m_scripts/shell-functions/base.sh"
rootCheck # function that does the checks for root/sudo

# Get test setup file for this test
test_name="remote-backup"
source "$m_test/$test_name/test-setup.sh"


# Copy test's import-config.sh into config/local for use by backup and import scripts
# If import-config.sh already exists, remove it.
if [ -f "$m_config/local/import-config.sh" ]; then
	rm "$m_config/local/import-config.sh"
fi
cp "$m_test/$test_name/import-config.sh" "$m_config/local/import-config.sh"

# source the import-config.sh for use by THIS script
source "$m_config/local/import-config.sh"


# Allow setting source server by passing as first (and only) arg to this script
# Else prompt for it
if [ ! -z "$1" ]; then
	source_server="$1"
else
	echo
	echo "Please include the source server IP address or hostname, e.g."
	echo "sudo bash run-test.sh 192.168.56.56"
	echo " - or -"
	echo "sudo bash run-test.sh example.com"
	exit 1
fi


# Create user
source "$m_scripts/shell-functions/add-user.sh"
add_ssh_user "$backup_user_name"

# generate SSH key
ssh-keygen -t rsa -N "" -f "/home/$backup_user_name/.ssh/id_rsa"
# --> Put SSH key on source server
scp "/home/$backup_user_name/.ssh/id_rsa.pub" "$source_root_user@$source_server:$temp_pub_key_path"

# Take $backup_user_name's private key and let root use it
mkdir -p "/root/.ssh"
chmod 700 "/root/.ssh"
cp "/home/$backup_user_name/.ssh/id_rsa" "/root/.ssh/id_rsa"

# Make a logs dir. Comes from import-config.sh
mkdir "$backup_logpath"
chmod 744 "$backup_logpath"

# SSH into source server,
ssh -q "$source_root_user@$source_server" "bash $m_test/$test_name/source-server-setup.sh"

# These should be modified in Git to make them 744 by default
# FIXME: Set permissions via Git
chmod 744 "$m_scripts/backup-remote-wikis.sh"
chmod 744 "$m_scripts/import-wikis-from-local-backup.sh"

# Run backup and import
bash "$m_scripts/backup-remote-wikis.sh"
bash "$m_scripts/import-wikis-from-local-backup.sh"

# Need to update extensions in case individual wikis have different reqs
# FIXME: So should import-wikis.sh update extensions for each wiki imported? An
# imported wiki won't function if additional extensions it requires aren't installed.
bash "$m_scripts/updateExtensions.sh"

# FIXME: why do we need this?
service httpd restart

echo "DONE"
