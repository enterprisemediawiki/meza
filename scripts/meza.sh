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
#		monolith  --> does `meza setup env local-monolith` for all-localhost, plus `meza deploy`
#		mw-app
#		db-master/slave
#		search-node
#		parsoid
#	setup
#		env
#		dev-networking --> alias for `meza install dev-networking`
#   deploy
#       optional tag
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

# Make sure this file exists
touch "$m_local_config_file"

# meza requires a command parameter. No first param, no command. Display help
if [ -z "$1" ]; then
	cat "$m_meza/manual/meza-cmd/base.txt"
	exit 0;
fi

# Every command has a directive. No second param, no directives. Display help
# for that specific directive.
if [ -z "$2" ]; then
	cat "$m_meza/manual/meza-cmd/$1.txt"
	exit 1;
fi

case "$1" in
	install)

		# base requirements for all meza installs
		mod_base="base base-extras"

		# mediawiki app server
		mod_app_initial="imagemagick apache php"

		# services
		mod_memcached="memcached"
		mod_db="db-server"
		mod_parsoid="parsoid"
		mod_elastic="elasticsearch"

		# more mediawiki app server stuff
		mod_app_final="mediawiki extensions"

		# security. @todo: FIXME can this be rolled into base module?
		mod_security="security"

		# dev-networking
		# monolith
		# mw-app
		# db-master/slave
		# search-node
		# parsoid
		case "$2" in
			"dev-networking")
				source "$m_scripts/dev-networking.sh"
				exit 0;
				;;
			"monolith")

				# Create a "monolith" environment
				cp -r "$m_meza/ansible/env/example" "$m_meza/ansible/env/monolith"

				# get domain from third arg if available, else prompt
				if [ ! -z "$3" ]; then
					monolith_ip="$3"
				else
					# Prompt for IP/domain
					meza prompt monolith_ip "Type the domain or IP address for this server"

					# Re-source after prompt
					source "$m_local_config_file"
				fi

				ssh-keyscan -H "$monolith_ip" >> /home/meza-ansible/.ssh/known_hosts

				# Make the IP/domain for every part of meza be the monolith IP
				sed -r -i "s/IP_ADDR/${monolith_ip}/g;" "$m_meza/ansible/env/monolith/hosts"

				meza deploy monolith

				exit 0;
				;;
			"app-with-remote-db")

				# Don't install the database server, just the client
				mod_db="db-client"
				modules="$mod_base thisisappserver $mod_app_initial $mod_memcached $mod_db $mod_parsoid $mod_elastic $mod_app_final $mod_security"
				meza config modules "$modules"

				# pseudo-monolithic setup
				meza config app_server_ips "localhost"

				"$m_scripts/install.sh"
				exit 0;
				;;
			"mw-app")
				# install just the mediawiki app server (PHP and like such as)
				echo "This function not created yet"
				exit 1;
				;;
			"db-master")
				meza config modules "base db-server db-remote"
				"$m_scripts/install.sh"
				exit 1;
				;;
			"db-slave")
				meza config modules "base db-server db-remote db-slave"
				"$m_scripts/install.sh"
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
			"modules")
				if [ -z "$3" ]; then
					cat "$m_meza/manual/meza-cmd/$1-$2.txt"
					exit 1;
				fi

				# Install list of modules
				#             $1      $2      $3
				# (sudo) meza install modules "list of space-separated modules"
				echo "This function not created yet"
				exit 1;
				;;

			"ansible")

				modules="$mod_base ansible"
				meza config modules "$modules"

				"$m_scripts/install.sh"
				exit 0;
				;;
			*)
				echo "NOT A VALID INSTALL COMMAND"
				exit 1;
				;;
		esac
		;;

	deploy)
		# FIXME: this should be dynamic
		env_dir="/opt/meza/ansible/env"
		ansible_env="$2"
		if [ ! -d "$env_dir/$ansible_env" ]; then
			echo
			echo "\"$ansible_env\" is not a valid environment."
			echo "Please choose one of the following:"
			echo
			for d in $env_dir/*/ ; do echo "`basename $d`"; done;
			exit 1;
		fi

		host_file="$env_dir/$ansible_env/hosts"
		if [ ! -f "$host_file" ]; then
			echo
			echo "$host_file not a valid file"
			exit 1;
		fi

		# This breaks continuous integration. FIXME to get it back.
		# echo
		# echo "You are about to deploy to the $ansible_env environment"
		# read -p "Do you want to proceed? " -n 1 -r
		# echo
		# if [[ $REPLY =~ ^[Yy]$ ]]
		# then
			# do dangerous stuff

			# stuff below was in here
		# fi


		# Get errors with user meza-ansible trying to write to the calling-user's
		# home directory if don't cd to a neutral location. FIXME.
		starting_wd=`pwd`
		cd /opt

		sudo -u meza-ansible ansible-playbook /opt/meza/ansible/site.yml -i "$host_file" ${@:3}

		cd "$starting_wd"

		;;

	setup)
		case "$2" in
			"env")
				echo "nope, not yet"
				;;
			*)
				echo "NOT A VALID SETUP COMMAND"
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
		if [ ! -f "$m_local_config_file" ]; then
			# No local config file; create one.
			echo -e "#!/bin/sh\n#\n# Local config overriding /opt/meza/config/core/config.sh\n" > "$m_local_config_file"
		fi

		source "$m_local_config_file"
		var_name="$2"
		new_val="$3"
		eval current_val=\$$var_name

		# No value, so just getting value
		if [ -z "$new_val" ]; then
			# no current value, so nothing to get
			if [ -z "$current_val" ]; then
				exit 1; # exit with failure exit code
			else
				echo "$current_val"
				exit 0;
			fi
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

			eval "$var_name=\"$new_val\""
			var_in_config_file=`grep "^$var_name=" "$m_local_config_file"`

			if [ "$current_val" = "$new_val" ]; then
				echo "'$var_name' already set to '$print_current_val' in $m_local_config_file"
				echo

			elif [ -z "$var_in_config_file" ]; then
				# var_name not already in config.local.sh, append it
				echo -e "\n\n$var_name=\"$new_val\"\n" >> "$m_local_config_file"

				echo "Adding '$var_name' value '$print_new_val' to $m_local_config_file"
				echo

			else
				# var_name already present, replace it
				sed -i "s/^$var_name=.*$/$var_name=\"$new_val\"/g" "$m_local_config_file"

				echo "Changing '$var_name' value in $m_local_config_file"
				echo "  FROM: '$print_current_val'"
				echo "  TO:   '$print_new_val'"
				echo
			fi

		fi
		;;

	prompt)

		# $1 = prompt
		prompt_var="$2"
		prompt_description="$3 and press [ENTER]:"
		prompt_prefill="$4"

		source "$m_local_config_file"
		eval prompt_value=\$$prompt_var


		while [ -z "$prompt_value" ]; do

			echo -e "\n$prompt_description"

			# If $prompt_prefill not null/empty/""
			if [ -n "$prompt_prefill" ]; then

				# If prefill suggestion given, display it and prompt user for changes
				read -e -i "$prompt_prefill" prompt_value

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
		prompt_description="$3 and press [ENTER]:"
		prompt_default="$4"

		source "$m_local_config_file"
		eval prompt_value=\$$prompt_var

		if [ -z "$prompt_value" ]; then

			echo -e "\n$prompt_description"
			read prompt_value

			prompt_value=${prompt_value:-$prompt_default}
		fi

		meza config "$prompt_var" "$prompt_value"
		;;

	prompt_secure)

		# $1 = prompt
		prompt_var="$2"

		source "$m_local_config_file"
		eval prompt_value=\$$prompt_var

		if [ -z "$prompt_value" ]; then

			# Generate a password
			gen_password_length=${4:-32} # get password length from $4 or use default 32
			def_chars="a-zA-Z0-9\!@#\$%^&*"
			gen_password_chars=${5:-$def_chars} # get allowable chars from $5 or use default
			gen_password=`cat /dev/urandom | tr -dc "$gen_password_chars" | fold -w $gen_password_length | head -n 1`

			prompt_description="$3 and press [ENTER]:\n(or leave blank to generate $gen_password_length-character password)"

			echo -e "\n$prompt_description"
			read -s prompt_value

			prompt_value=${prompt_value:-$gen_password}

		fi

		meza config "$prompt_var" "$prompt_value" quiet
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
