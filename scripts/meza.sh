#!/bin/sh
#
# meza command
#
# Call like:
# sudo meza install dev-networking
# sudo meza install
#
# Planning docs below for now...
#
#	MEZA command (Mediawiki EZ Admin)
#	============
#	install
#		dev-networking
#		monolith
#		mw-app
#		db-master/slave
#		search-node
#		parsoid
#	create
#		wiki
#		user
#	destroy
#		wiki
#	update
#		meza
#		extensions (which wikis, which extensions)
#		search (rebuild index)
#	import
#		local
#		remote (fileshare)
#		remote (scp,ssh,meza,nonmeza)
#	config
#		set: sudo meza config <key> <value>
#		get: meza config <key>
#	samba
#	saml
#	unify
#	test
#		ssl
#		import & check
#	config
#		prompt for: all wikis? specific wiki?
#			prompt for: pre or post (give info on what each is for)

source "/opt/meza/config/core/config.sh"

# no first parameter? display help
if [ -z "$1" ]; then
	cat "$m_meza/manual/meza-command-help.txt"
	exit 0;
fi


case "$1" in
	install)
		# dev-networking
		# monolith
		# mw-app
		# db-master/slave
		# search-node
		# parsoid
		case "$2" in
			"dev-networking")
				# do dev networking stuff
				"$m_scripts/dev-networking.sh"
				exit 0;
				;;
			"monolith")
				"$m_scripts/install.sh"
				exit 0;
				;;
			"mw-app")
				# install just the mediawiki app server (PHP and like such as)
				echo "This function not created yet"
				exit 1;
				;;
			"db-master")
				# do stuff
				echo "This function not created yet"
				exit 1;
				;;
			"db-slave")
				# do stuff
				echo "This function not created yet"
				exit 1;
				;;
			"search-node")
				# do stuff
				echo "This function not created yet"
				exit 1;
				;;
			"parsoid")
				# do stuff
				echo "This function not created yet"
				exit 1;
				;;
			*)
				echo "NOT A VALID INSTALL COMMAND"
				exit 1;
				;;
		esac
		;;

	create)
		case "$2" in
			"wiki")
				"$m_scripts/create-wiki.sh"
				exit 0;
				;;

			*)
				echo "Not a valid CREATE command"
				exit 1;
				;;
		esac
		;;

	destroy)
		echo "This function not created yet"
		exit 1;
		;;

	update)
		echo "This function not created yet"
		exit 1;
		;;

	config)
		# $2 is key
		# $3 is optional, and is value to set to key
		local_config_file="$m_config/local/config.local.sh"
		if [ ! -f "$local_config_file" ]; then
			echo -e "#!/bin/sh\n#\n# Local config overriding /opt/meza/config/core/config.sh\n" > "$local_config_file"
		fi

		source "$local_config_file"
		var_name="$2"
		new_val="$3"
		eval current_val=\$$var_name

		# No value, so just getting value
		if [ -z "$new_val" ]; then
			echo "$current_val"
			exit 0;
		else

			# for not echoing values in terminal, for passwords and such
			quiet="$4"

			if [ "$current_val"="new_val" ]; then
				if [ "$quiet"="quiet" ]; then
					current_val="<hidden-value>"
				fi

				echo "'$var_name' already set to '$current_val' in $local_config_file"
				echo

			elif [ -z `grep "^$var_name=" "$local_config_file"` ]; then
				# var_name not already in config.local.sh, append it
				echo -e "\n\n$var_name=$new_val\n" >> "$local_config_file"

				if [ "$quiet"="quiet" ]; then
					new_val="<hidden-value>"
				fi

				echo "Adding '$var_name' value '$new_val' to $local_config_file"
				echo

			else
				# var_name already present, replace it
				sed -i "s/^$var_name=.*$/$var_name=\"$new_val\"/g" "$local_config_file"

				if [ "$quiet"="quiet" ]; then
					current_val="<hidden-value>"
					new_val="<hidden-value>"
				fi

				echo "Changing '$var_name' value in $local_config_file"
				echo "  FROM: '$current_val'"
				echo "  TO:   '$new_val'"
				echo
			fi

		fi
		;;

	maint)
		case "$2" in
			"jobs")
				anywiki=`ls -d /opt/meza/htdocs/wikis/*/ | tail -1`
				anywiki=`basename $anywiki`
				if [ ! -z "$3" ]; then
					WIKI="$anywiki" php "$m_scripts/runAllJobs.php" "--wikis=$3"
				else
					WIKI="$anywiki" php "$m_scripts/runAllJobs.php"
				fi
				exit 0;
				;;

			*)
				echo "Not a valid MAINT command"
				exit 1;
				;;
		esac
		;;

	import)
		echo "This function not created yet"
		exit 1;
		;;

	# not a valid command, show help and exit with error code
	*)
		cat "/opt/meza/manual/meza-command-help.txt"
		exit 1;

esac
