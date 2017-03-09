#!/bin/sh
#
# Shell function to add a user with a properly setup SSH directory

add_ssh_user() {

	useradd "$1"
	mkdir -p "/home/$1/.ssh"
	chown "$1" "/home/$1/.ssh"
	chmod 700 "/home/$1/.ssh"

}
