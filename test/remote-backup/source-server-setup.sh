#!/bin/sh
#
# Setup source server where backups are retrieved from
# This must be performed after backup server steps

source "/opt/meza/config/core/config.sh"
source "$m_scripts/shell-functions/base.sh"
rootCheck # function that does the checks for root/sudo

# Get test setup file for this test
test_name="remote-backup"
source "$m_test/$test_name/test-setup.sh"


# Create user for backup
source "$m_scripts/shell-functions/add-user.sh"
add_ssh_user "$backup_user_name"

# Apply public key (which was transferred from backup server) to authorized_keys
cat "$temp_pub_key_path" >> "/home/$backup_user_name/.ssh/authorized_keys"
rm "$temp_pub_key_path"
chmod 600 "/home/$backup_user_name/.ssh/authorized_keys"

