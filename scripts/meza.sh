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
				meza config is_app_server true
				meza config setup_database true
				meza config setup_database_server true
				meza config is_remote_db_server false
				meza config setup_parsoid true
				meza config setup_elasticsearch true
				"$m_scripts/install.sh"
				exit 0;
				;;
			"app-with-remote-db")
				meza config is_app_server true
				meza config setup_database true
				meza config setup_database_server false
				meza config is_remote_db_server false
				meza config setup_parsoid true
				meza config setup_elasticsearch true

				# meza prompt db_server

				"$m_scripts/install.sh"
				exit 0;
				;;
			"mw-app")
				# install just the mediawiki app server (PHP and like such as)
				echo "This function not created yet"
				exit 1;
				;;
			"db-master")
				meza config setup_database true
				meza config setup_database_server true
				meza config is_remote_db_server true
				"$m_scripts/install.sh"
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
			if [ "$quiet" = "quiet" ]; then
				print_new_val="<hidden-value>"
				print_current_val="<hidden-value>"
			else
				print_new_val="$new_val"
				print_current_val="$current_val"
			fi

			eval "$var_name=$new_val"

			if [ "$current_val" = "$new_val" ]; then
				echo "'$var_name' already set to '$print_current_val' in $local_config_file"
				echo

			elif [ -z `grep "^$var_name=" "$local_config_file"` ]; then
				# var_name not already in config.local.sh, append it
				echo -e "\n\n$var_name=\"$new_val\"\n" >> "$local_config_file"

				echo "Adding '$var_name' value '$print_new_val' to $local_config_file"
				echo

			else
				# var_name already present, replace it
				sed -i "s/^$var_name=.*$/$var_name=\"$new_val\"/g" "$local_config_file"

				echo "Changing '$var_name' value in $local_config_file"
				echo "  FROM: '$print_current_val'"
				echo "  TO:   '$print_new_val'"
				echo
			fi

		fi
		;;

	prompt)
		# $1 = prompt
		prompt_var="$2"
		prompt_description="$3"
		prompt_prefill="$4"
		while [ -z "$prompt_value" ]; do

			echo -e "\n$prompt_description"

			# If $prompt_prefill not null/empty/""
			if [ -n "$prompt_prefill" ]; then

				# If prefill suggestion given, display it and prompt user for changes
				read -e -i $prompt_prefill prompt_value

			else
				# no prefill, force user to enter
				read -e prompt_value
			fi

		done

		meza config "$prompt_var" "$prompt_value"
		;;

	prompt_default_on_blank)
		# $1 = prompt
		prompt_var="$2"
		prompt_description="$3"
		prompt_default="$4"

		echo -e "\n$prompt_description"
		read prompt_value

		prompt_value=${prompt_value:-$prompt_default}

		meza config "$prompt_var" "$prompt_value"
		;;

	prompt_secure)
		# $1 = prompt
		prompt_var="$2"

		# Generate a password
		gen_password_length=${4:-32} # get password length from $4 or use default 32
		def_chars="a-zA-Z0-9\!@#\$%^&*"
		gen_password_chars=${5:-$def_chars} # get allowable chars from $5 or use default
		gen_pass=`cat /dev/urandom | tr -dc "$chars" | fold -w $len | head -n 1`

		prompt_description="$3\n(or press [enter] to generate $gen_password_length character password)"

		echo -e "\n$prompt_description\n"
		read -s prompt_value

		prompt_value=${prompt_value:-$prompt_default}
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
