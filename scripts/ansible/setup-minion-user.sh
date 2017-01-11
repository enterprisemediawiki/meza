#!/bin/sh
#
# Create user to act as an Ansible minion. Requirements:
#   1. Create user
#   2. Add public key to authorized_keys
#   3. Make user a passwordless sudoer


# Load config constants. Unfortunately right now have to write out full path to
# meza since we can't be certain of consistent method of accessing install.sh.
source "/opt/meza/config/core/config.sh"

source "$m_scripts/shell-functions/base.sh"
rootCheck

source "$m_scripts/shell-functions/linux-user.sh"

# This will be re-sourced after prompts to get modified config, but needs to be
# here mostly to get $modules variable
source "$m_local_config_file"

# i18n message file
source "$m_i18n/$m_language.sh"

if [ -z "$1" ]; then
	echo "Please add the desired SSH public key as the first argument to this command"
	echo "example: ./setup-ansible-minion.sh <your public key here>"
	exit 1;
fi

mf_add_public_user_with_public_key "$ansible_user" "$1"

# Add $ansible_user to sudoers as a passwordless user
bash -c "echo '$ansible_user ALL=(ALL) NOPASSWD: ALL' | (EDITOR='tee -a' visudo)"
