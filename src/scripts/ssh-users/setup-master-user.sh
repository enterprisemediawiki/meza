#!/bin/sh
#
# Create user to act as an Ansible master. Requirements:
#   1. Create user
#   2. Generate SSH key pair
#   3. Print public key and inform to put on minions

# Load config constants. Unfortunately right now have to write out full path to
# meza since we can't be certain of consistent method of accessing install.sh.
source "/opt/.deploy-meza/config.sh"

source "$m_scripts/shell-functions/base.sh"
rootCheck

source "$m_scripts/shell-functions/linux-user.sh"

# Create $ansible_user user with a new private key
mf_add_ssh_user_with_private_key "$ansible_user"

# Also add the public key to user's authorized_keys, such that they are able to
# SSH into this server. This is sort of weird, but it enables ansible to
# cleanly allow the master server to also fill one or more minion roles
cat "$meza_user_dir/$ansible_user/.ssh/id_rsa.pub" >> "$meza_user_dir/$ansible_user/.ssh/authorized_keys"
chmod 600 "$meza_user_dir/$ansible_user/.ssh/authorized_keys"
chown -R "$ansible_user:$ansible_user" "$meza_user_dir/$ansible_user/.ssh"

# Add $ansible_user to sudoers as a passwordless user
echo "$ansible_user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/meza-ansible


# echo
# echo
# echo "User $ansible_user setup. Please copy the SSH public key below and use"
# echo "it when setting up minion servers. Usage:"
# echo "/opt/meza/src/scripts/ansible/setup-minion-user.sh <paste key here>"
# echo
# cat "$meza_user_dir/$ansible_user/.ssh/id_rsa.pub"
