#!/bin/sh
#
# Shell functions to add and modify linux users

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
	if ! mf_user_exists "$1"; then
		useradd "$1"
	fi

	mkdir -p "/home/$1/.ssh"
	chown "$1" "/home/$1/.ssh"
	chmod 700 "/home/$1/.ssh"
}

mf_add_ssh_user_with_private_key() {
	mf_add_ssh_user "$1"
	ssh-keygen -f "/home/$1/.ssh/id_rsa" -t rsa -N '' -C "$1@`hostname`"
}

mf_add_public_user_with_public_key () {
	mf_add_ssh_user "$1"

	if [ -z "$2" ]; then
		echo "mf_add_public_user_with_public_key requires a public key as second argument"
		exit 1;
	fi

	# FIXME: use best practices to ensure file gets deleted
	tmpfile=$(mktemp /tmp/pub.XXXXXX)
	"$2" > "$tmpfile"
	importkey_check=`ssh-keygen -l -f "$tmpfile"`
	if [ "$importkey_check" = "$tmpfile is not a public key file." ]; then
		echo "The following is not a valid public key:"
		echo
		echo "$2"
		echo
		exit 1;
	else

	"$2" >> "/home/$1/.ssh/authorized_keys"
	chmod 600 "/home/$1/.ssh/authorized_keys"
	chown "$1" "/home/$1/.ssh/authorized_keys"
}
