#!/bin/bash
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
#		dev --> setup ftp, git
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

source "$m_i18n/$m_language.sh"


prompt () {

	prompt_var="$1"
	prompt_description="$2 and press [ENTER]:"
	prompt_prefill="$3"

	# FIXME: test escaping. See `printf -v ...` at bottom of function
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

	# Escaping $prompt_value is important. Both eval and typeset/declare
	# methods can fail. printf to a variable seems mroe robust.
	# eval $prompt_var=$prompt_value
	# typeset $prompt_var="$gen_password"
	printf -v "${prompt_var}" '%s' "${prompt_value}"
}

# $1 = prompt variable (the var you want set)
# $2 = prompt description
# $3 = auto-generated password length (number of characters)
# $4 = acceptable characters for auto-generated password
prompt_secure () {

	prompt_var="$1"

	# Generate a password
	gen_password_length=${3:-32} # get password length from $4 or use default 32

	# Ansible doesn't like characters with # symbols
	def_chars="a-zA-Z0-9\!@\$%^&*"

	gen_password_chars=${4:-$def_chars} # get allowable chars from $5 or use default
	gen_password=`cat /dev/urandom | tr -dc "$gen_password_chars" | fold -w $gen_password_length | head -n 1`

	prompt_description="$2 and press [ENTER]:\n(or leave blank to generate $gen_password_length-character password)"

	echo -e "\n$prompt_description"
	read -s prompt_value

	if [ -z "$prompt_value" ]; then
		printf -v "${prompt_var}" '%s' "${gen_password}"
	else
		printf -v "${prompt_var}" '%s' "${prompt_value}"
	fi

}

check_environment () {

	ansible_env="$1"

	# FIXME: this should be dynamic
	env_dir="/opt/meza/ansible/env"
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

}

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

				# If a "monolith" environment doesn't already exist, create one
				if [ ! -d "$m_meza/ansible/env/monolith" ]; then

					# Prompt for domain, DB password, whether to enable email
					# Skip prompts for private net zone (no need in monolith)
					private_net_zone=public meza setup env monolith

				fi

				meza deploy monolith ${@:3}

				exit $?;
				;;

			# Perhaps consider common setups like:
			# "monolith-with-remote-db-master")
			# "monolith-with-remote-db-slave")
			# "duolith" <-- two mega servers, identical, except one has slave DB
			# "triolith" <-- three mega servers, identical, two with slave DBs
			*)
				echo "NOT A VALID INSTALL COMMAND"
				exit 1;
				;;
		esac
		;;

	deploy)

		check_environment "$2"
		host_file="/opt/meza/ansible/env/$2/hosts"

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
		exit $?;

		;;

	setup)
		case "$2" in
			"env")

				if [ -z "$3" ]; then
					echo
					echo "Please include a valid environment name"
					exit 1;
				fi

				# If environment doesn't already exist, create it
				if [ ! -d "$m_meza/ansible/env/$3" ]; then

					# Copy the template environment
					cp -r "$m_meza/ansible/template-env/blank" "$m_meza/ansible/env/$3"

					# allow setting required params (and other params) with a file
					if [ -f "$4" ]; then
						source "$4"

					# If required params somehow already set, use them
					# Could be done like:
					#   fqdn=enterprisemediawiki.org \
					#   db_pass=1234 \
					#   email=false \
					#   private_net_zone=public \
					#   meza setup env test-env
					# This will put the DB password on the command line, so
					# should only be done in testing cases
					elif [ ! -z "$fqdn" ] && [ ! -z "$db_pass" ] && [ ! -z "$email" ] && [ ! -z "$private_net_zone" ]; then
						echo "All required params defined, skipping prompts."
					else
						prompt "fqdn" "$MSG_prompt_fqdn"
						prompt_secure "db_pass" "$MSG_prompt_db_password"
						prompt "email" "$MSG_prompt_enable_email" "true"
						if [ "$3" = "monolith" ]; then
							private_net_zone="public"
						else
							prompt "private_net_zone" "$MSG_prompt_private_net_zone" "public"
						fi
					fi

					# Make sure required params are present, or exit.
					if [ -z "$fqdn" ]; then             echo "Missing fqdn param";             exit 1; fi;
					if [ -z "$db_pass" ]; then          echo "Missing db_pass param";          exit 1; fi;
					if [ -z "$email" ]; then            echo "Missing email param";            exit 1; fi;
					if [ -z "$private_net_zone" ]; then echo "Missing private_net_zone param"; exit 1; fi;

					# escape vars prior to sed
					fqdn=$(echo "$fqdn" | sed -e 's/[\/&]/\\&/g')
					db_pass=$(echo "$db_pass" | sed -e 's/[\/&]/\\&/g')
					email=$(echo "$email" | sed -e 's/[\/&]/\\&/g')
					private_net_zone=$(echo "$private_net_zone" | sed -e 's/[\/&]/\\&/g')

					sed -r -i "s/INSERT_FQDN/$fqdn/g;"                         "$m_meza/ansible/env/$3/group_vars/all.yml"
					sed -r -i "s/INSERT_PRIVATE_ZONE/$private_net_zone/g;"     "$m_meza/ansible/env/$3/group_vars/all.yml"
					sed -r -i "s/INSERT_ENABLE_EMAIL/$email/g;"                "$m_meza/ansible/env/$3/group_vars/all.yml"

					# All DB users used by the application (root, app, slave)
					# have the same password. Update as required.
					sed -r -i "s/INSERT_MYSQL_ROOT_PASS/$db_pass/g;"           "$m_meza/ansible/env/$3/group_vars/all.yml"
					sed -r -i "s/INSERT_WIKI_APP_DB_USER_PASSWORD/$db_pass/g;" "$m_meza/ansible/env/$3/group_vars/all.yml"
					sed -r -i "s/INSERT_SLAVE_PASSWORD/$db_pass/g;"            "$m_meza/ansible/env/$3/group_vars/all.yml"

					# For monolith, make the IP/domain for every part of meza
					# be localhost. All other cases make user edit inventory
					# (AKA "hosts") file
					# NOTE: "INSERT_SLAVE" not in monolith list, so as not to
					#       configure the monolith as DB master _and_ slave
					if [ "$3" = "monolith" ]; then
						for part in INSERT_LB INSERT_APP INSERT_MEM INSERT_MASTER INSERT_PARSOID INSERT_ES; do
							sed -r -i "s/# $part/localhost/g;" "$m_meza/ansible/env/$3/hosts"
						done
					else

						# If any of these variables are defined, put them into inventory file
						for INVENTORY_VARNAME in INSERT_LB INSERT_APP INSERT_MEM INSERT_MASTER INSERT_SLAVE INSERT_PARSOID INSERT_ES; do

							# Make INVENTORY_VALUE be the value of a variable with the name in INVENTORY_VARNAME
							# printf -v "${INVENTORY_VARNAME}" '%s' "${INVENTORY_VARNAME}"
							eval INVENTORY_VALUE="\$$INVENTORY_VARNAME"

							if [ ! -z "$INVENTORY_VALUE" ]; then
								# Excape value before doing sed-insertion
								INVENTORY_VALUE=$(echo "$INVENTORY_VALUE" | sed -e 's/[\/&]/\\&/g')
								sed -r -i "s/# $INVENTORY_VARNAME/$INVENTORY_VALUE/g;" "$m_meza/ansible/env/$3/hosts"
							fi
						done

						echo
						echo "Please edit your inventory file to add or confirm the proper servers."
						echo "Run command:  sudo vi $m_meza/ansible/env/$3/hosts"
					fi

				fi


				;;
			"dev")
				/opt/meza/scripts/setup-dev.sh
				;;
			*)
				echo "NOT A VALID SETUP COMMAND"
				exit 1;
				;;
		esac
		;;

	create)

		case "$2" in
			"wiki" | "wiki-promptless")

				if [ ! -z "$3" ]; then
					environment="$3"
				else
					echo
					echo "You must specify an environment: 'meza create wiki ENV'"
					exit 1;
				fi

				check_environment "$environment"
				host_file="/opt/meza/ansible/env/$environment/hosts"

				# Get errors with user meza-ansible trying to write to the calling-user's
				# home directory if don't cd to a neutral location. FIXME.
				starting_wd=`pwd`
				cd /opt

				if [ "$2" == "wiki-promptless" ]; then
					if [ -z "$4" ]; then echo "Please specify a wiki ID"; exit 1; fi
					if [ -z "$5" ]; then echo "Please specify a wiki name"; exit 1; fi
					playbook="create-wiki-promptless.yml"
					sudo -u meza-ansible ansible-playbook "/opt/meza/ansible/$playbook" -i "$host_file" --extra-vars  "wiki_id=$4 wiki_name='$5'" ${@:6}
				else
					playbook="create-wiki.yml"
					sudo -u meza-ansible ansible-playbook "/opt/meza/ansible/$playbook" -i "$host_file" ${@:4}
				fi

				cd "$starting_wd"
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
		;;

esac
