#!/bin/sh
#
# shell-functions/base.sh
#
# A bunch of functions used throughout multiple script files

# Makes an obvious print statement for titling a section or start of a script
# Basically this just makes it easy to see when things start
printTitle() {

cat << EOM

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*                                                             *
*  $1
*                                                             *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

EOM

}


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

prompt_mysql_root_pass() {
	# prompt user for MySQL root password
	while [ -z "$mysql_root_pass" ]
		do
		echo -e "\nEnter MySQL root password and press [ENTER]: "
		read -s mysql_root_pass
	done
}

# Count how many arguments a string breaks into, e.g. if you do:
#     myvar="one two three"
#     countargs $myvar
# It will return 3. Note that you can't quote the variable.
mf_countargs() { echo $#; }

# Trim whitespace from an input
mf_trimwhitespace() { echo -e "$*" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'; }

