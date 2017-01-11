#!/bin/sh
#
# Create user to act as an Ansible master. Requirements:
#   1. Create user
#   2. Generate SSH key pair
#   3. Print public key and inform to put on minions

# Load config constants. Unfortunately right now have to write out full path to
# meza since we can't be certain of consistent method of accessing install.sh.
source "/opt/meza/config/core/config.sh"

source "$m_scripts/shell-functions/base.sh"
rootCheck

source "$m_scripts/shell-functions/linux-user.sh"

# Create $ansible_user user with a new private key
mf_add_ssh_user_with_private_key "$ansible_user"

echo
echo
echo "User $ansible_user setup. Please copy the SSH public key below and use"
echo "it when setting up minion servers. Usage:"
echo "/opt/meza/scripts/ansible/setup-minion-user.sh <paste key here>"
echo
echo "key (don't copy this line):"
echo
cat "/home/$ansible_user/.ssh/id_rsa.pub"




