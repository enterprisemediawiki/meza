#!/bin/sh
#
# Shell functions to add and modify linux users

# Don't create meza application users under /home, ref: #727
meza_user_dir="/opt/conf-meza/users"

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

mf_add_ssh_user() {
	mkdir -p "$meza_user_dir"
	chown root:root "$meza_user_dir"
	chmod 755 "$meza_user_dir"

	if ! mf_user_exists "$1"; then
		useradd "$1" --home-dir "$meza_user_dir/$1"
	fi

	mkdir -p "$meza_user_dir/$1/.ssh"
	chown -R "$1:$1" "$meza_user_dir/$1/.ssh"
	chmod 700 "$meza_user_dir/$1/.ssh"

	# Make sure user dir properly owned. Not having this was never an issue on
	# RedHat, but causes errors on Debian.
	chown "$1:$1" "$meza_user_dir/$1"
}

mf_add_ssh_user_with_private_key() {
	mf_add_ssh_user "$1"
	if [ -f "$meza_user_dir/$1/.ssh/id_rsa" ]; then
		echo "SSH keys exist for user $1. Moving on."
	else
		ssh-keygen -f "$meza_user_dir/$1/.ssh/id_rsa" -t rsa -N '' -C "$1@`hostname`"
	fi
	chown -R "$1:$1" "$meza_user_dir/$1/.ssh"
}

mf_add_public_user_with_public_key () {
	mf_add_ssh_user "$1"

	if [ -z "$2" ]; then
		echo "mf_add_public_user_with_public_key requires a public key as second argument"
		exit 1;
	fi

	tmpfile=$(mktemp /tmp/pub.XXXXXX)
	echo "$2" >> "$tmpfile"
	importkey_check=`ssh-keygen -l -f "$tmpfile"`
	rm -f "$tmpfile"
	if [ "$importkey_check" = "$tmpfile is not a public key file." ]; then
		echo "The following is not a valid public key:"
		echo
		echo "$2"
		echo
		exit 1;
	fi

	echo "$2" >> "$meza_user_dir/$1/.ssh/authorized_keys"
	chmod 600 "$meza_user_dir/$1/.ssh/authorized_keys"
	chown -R "$1:$1" "$meza_user_dir/$1/.ssh"
}
