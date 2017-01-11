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

echo "Type space-separated list of minions to copy SSH"
read -e minions

for minion in $minions; do

	# Copy id_rsa.pub to each minion
	ssh-copy-id "$ansible_user@$minion"

	# Remove password-based authentication for $ansible_user
	ssh "$ansible_user@$minion" "sudo passwd --delete $ansible_user"

done
