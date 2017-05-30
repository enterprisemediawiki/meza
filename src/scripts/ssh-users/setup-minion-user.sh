#!/bin/sh
#
# Create user to act as an Ansible minion. Requirements:
#   1. Create user
#   2. Add public key to authorized_keys
#   3. Make user a passwordless sudoer


#
# The following function is from shell-functions/base.sh and is included here
# because:
#   [1]: To make it possible to just download this script without the rest of
#        the meza repository. This script will be run on minion servers that
#        don't necessarily require the whole repo, and if they do they will be
#        controlled by the master.
#
meza_user_dir="/opt/conf-meza/users"

rootCheck() {
	# must be root or sudoer
	if [ "$(whoami)" != "root" ]; then
		echo "Root required: Run this script preceded by 'sudo' command"
		exit 1
	fi

	# If /usr/local/bin is not in PATH then add it
	# Ref enterprisemediawiki/meza#68 "Run install.sh with non-root user"
	if [[ $PATH != *"/usr/local/bin"* ]]; then
		PATH="/usr/local/bin:$PATH"
	fi
}

#
# The following functions are from shell-functions/linux-user.sh and are
# included here due to [1] above.
#
mf_add_ssh_user() {
	if [ ! -d "$meza_user_dir" ]; then
		mkdir -p "$meza_user_dir"
		chown root:root "$meza_user_dir"
		chmod 755 "$meza_user_dir"
	fi

	if ! mf_user_exists "$1"; then
		useradd "$1" --home-dir "$meza_user_dir/$1"
	fi

	mkdir -p "$meza_user_dir/$1/.ssh"
	chown -R "$1:$1" "$meza_user_dir/$1/.ssh"
	chmod 700 "$meza_user_dir/$1/.ssh"
}
mf_user_exists() {
	ret=false
	getent passwd $1 >/dev/null 2>&1 && ret=true

	if $ret; then
	    # user exists (bash 0 for true, yuck)
	    return 0
	else
	    return 1
	fi
}

rootCheck

# i18n message file not included here due to [1] above.
# source "$m_i18n/$m_language.sh"

# Was `mf_add_ssh_user "$ansible_user"` but hard-coding user due to [1] above
mf_add_ssh_user "meza-ansible"


if [ -f /tmp/meza-ansible.id_rsa.pub ]; then
	cat /tmp/meza-ansible.id_rsa.pub >> /opt/conf-meza/users/meza-ansible/.ssh/authorized_keys
	passwd --delete meza-ansible
else
	echo
	echo "Add a temporary password for meza-ansible. This password can be deleted after"
	echo "SSH keys are setup. Script 'transfer-master-key.sh' will auto-delete password."
	passwd "meza-ansible"
fi

# Add $ansible_user to sudoers as a passwordless user
bash -c "echo 'meza-ansible ALL=(ALL) NOPASSWD: ALL' | (EDITOR='tee -a' visudo)"
