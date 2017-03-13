mf_createDBuser () {
	user="$1"
	ipaddr="$2"
	pass="$3"
	grants="$4"
	if [ -z "$user" ]; then
		echo "createDBuser needs a user specified"
		exit 1;
	fi
	if [ -z "$ipaddr" ]; then
		echo "createDBuser needs an IP address specified"
		exit 1;
	fi
	if [ -z "$pass" ]; then
		echo "createDBuser needs a password specified"
		exit 1;
	fi
	if [ -z "$grants" ]; then
		echo "createDBuser needs permisions to be granted specified"
		exit 1;
	fi
	if [ -z "$mysql_root_pass" ]; then
		echo "createDBuser needs mysql_root_pass to be specified"
		exit 1;
	fi
	displayquery=`cat <<EOF
		CREATE USER '$user'@'$ipaddr' IDENTIFIED BY '<password-hidden>';
		GRANT $grants ON *.* TO '$user'@'$ipaddr';
		FLUSH PRIVILEGES;
EOF`
	runquery=`cat <<EOF
		CREATE USER '$user'@'$ipaddr' IDENTIFIED BY '$pass';
		GRANT $grants ON *.* TO '$user'@'$ipaddr';
		FLUSH PRIVILEGES;
EOF`
	echo
	echo "Running query:"
	echo "$displayquery"
	mysql -u root "--password=$mysql_root_pass" -e"$runquery"
}
