#!/usr/bin/env python
#
# meza command
#
# FIXME: get commented out notes from meza.sh and make sure documented

import sys, getopt


# how to do this in Python
FIXME: source "/opt/meza/config/core/config.sh"



print 'Number of arguments:', len(sys.argv), 'arguments.'
print 'Argument List:', str(sys.argv)


getopt.getopt(args, options, [long_options])





def FIXME argHandling(argv):
   inputfile = ''
   outputfile = ''
   try:
      opts, args = getopt.getopt(argv,"hi:o:",["ifile=","ofile="])
   except getopt.GetoptError:
      print 'test.py -i <inputfile> -o <outputfile>'
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print 'test.py -i <inputfile> -o <outputfile>'
         sys.exit()
      elif opt in ("-i", "--ifile"):
         inputfile = arg
      elif opt in ("-o", "--ofile"):
         outputfile = arg
   print 'Input file is "', inputfile
   print 'Output file is "', outputfile





def main (argv):

	# meza requires a command parameter. No first param, no command. Display
	# help. Also display help if explicitly specifying help.
	if len(argv) == 0 or argv[0] == '-h' or argv[0] == '--help':
		display_docs('base')
		sys.exit(1)

	# Every command has a directive. No second param, no directives. Display
	# help for that specific directive.
	if len(argv) == 1:
		display_docs(argv[0])
		sys.exit(1)

	FIXME source "$m_i18n/$m_language.sh"

	FIXME touch "$m_local_config_file"

	command = argv[0]
	command_fn = "meza_command_{}".format( argv[0] )

	# if command_fn is a valid Python function, pass it all remaining args
	if command_fn in locals() and callable( locals()[command_fn] ):
		locals()[command_fn]( argv[1:] )
	else:
		print
		print "{} is not a valid command".format(command)
		sys.exit(1)


def playbook_cmd ( playbook, env ):
	host_file = "/opt/meza/config/local-secret/{}/hosts".format(env)
	return ['sudo', '-u', 'meza-ansible', 'ansible-playbook',
		'/opt/meza/src/playbooks/{}.yml'.format(playbook), '-i', host_file,
		"--extra-vars", "env="+env ]

# FIXME install --> setup dev-networking, setup docker, deploy monolith (special case)

def meza_shell_exec ( shell_cmd ):

	# FIXME
	# Get errors with user meza-ansible trying to write to the calling-user's
	# home directory if don't cd to a neutral location. FIXME.
	starting_wd = os.getcwd()
	os.chdir( "/opt/meza/config/core" )

	import subprocess
	child = subprocess.Popen(shell_cmd, stdout=subprocess.PIPE)
	print child.communicate()[0]
	rc = child.returncode

	# FIXME: See above
	os.chdir( starting_wd )

	return rc


def meza_command_deploy (argv):

	env = argv[0]

	# first param to deploy should be environment
	check_environment(env)

	# This breaks continuous integration. FIXME to get it back.
	# THIS WAS WRITTEN WHEN `meza` WAS A BASH SCRIPT
	# echo "You are about to deploy to the $ansible_env environment"
	# read -p "Do you want to proceed? " -n 1 -r
	# if [[ $REPLY =~ ^[Yy]$ ]]; then
		# do dangerous stuff

		# stuff below was in here
	# fi

	shell_cmd = playbook_cmd( 'site', env )
	if len(argv) > 1:
		shell_cmd + argv[1:]

	return_code = meza_shell_exec( shell_cmd )

	# exit with same return code as ansible command
	sys.exit(return_code)



def meza_command_setup (argv):
	# env (complicated)
	# dev (simple shell-exec bash script)
	print "not yet built"


def meza_command_create (argv):
	# wiki
	# wiki-promptless
	print "not yet built"


def meza_command_backup (argv):
	print "not yet built"


def meza_command_destroy (argv):
	print "not yet built"


def meza_command_update (argv):
	print "not yet built"


def meza_command_maint (argv):
	print "not yet built"


def meza_command_docker (argv):
	print "not yet built"










def display_docs(name):
	f = open('/opt/meza/manual/meza-cmd/{}.txt'.format(name),'r')
	f.read()

def prompt(varname,default):
	print
	print FIXME i18n pretext
	FIXME[varname] = input( FIXME i18n varname )
	if default:
		# If there's a default, either use user entry or default
		FIXME[varname] = FIXME[varname] or default
	else:
		# If no default, keep asking until user supplies a value
		while (not FIXME[varname]):
			FIXME[varname] = input( FIXME i18n varname )


def prompt_secure(varname):
	import getpass

	print
	print FIXME i18n pretext
	FIXME[varname] = getpass.getpass( FIXME i18n varname )
	if not FIXME[varname]:
		FIXME[varname] = random_string()

def random_string(**params):

	if 'num_chars' in params:
		num_chars = params['num_chars']
	else:
		num_chars = 32

	if 'valid_chars' in params:
		valid_chars = params['valid_chars']
	else
		valid_chars = string.ascii_letters + string.digits + '!@$%^*'

	return ''.join(random.SystemRandom().choice(valid_chars) for _ in range(num_chars))



def check_environment(env):
	import os

	conf_dir = "/opt/meza/config/local-secret"

	env_dir = os.path.join( conf_dir, env )
	if not os.path.isdir( env_dir ):
		print
		print '"{}" is not a valid environment.'.format(env)
		print "Please choose one of the following:"

		# this gets all dirs within then env_dir dir
		valid_envs = os.walk( conf_dir ).next()[1]
		for valid_env in valid_envs:
			print valid_env

		sys.exit(1)

	host_file = os.path.join( env_dir, "hosts" )
	if not os.path.isfile( host_file ):
		print
		print "{} not a valid file".format( host_file )
		sys.exit(1)


if __name__ == "__main__":
   main(sys.argv[1:])





case "$1" in
	install)

		case "$2" in
			"dev-networking")
				source "$m_scripts/dev-networking.sh"
				exit 0;
				;;
			"monolith")

				# If a "monolith" environment doesn't already exist, create one
				if [ ! -d "$m_meza/config/local-secret/monolith" ]; then

					# Prompt for domain, DB password, whether to enable email
					# Skip prompts for private net zone (no need in monolith)
					private_net_zone=public meza setup env monolith

				fi

				meza deploy monolith ${@:3}

				exit $?;
				;;

			"docker")
				# Local playbook only, doesn't need to be run by meza-ansible user
				ansible-playbook /opt/meza/src/playbooks/getdocker.yml
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


	setup)
		case "$2" in
			"env")

				if [ -z "$3" ]; then
					echo
					echo "Please include a valid environment name"
					exit 1;
				fi

				if [ ! -d "$m_meza/config/local-secret" ]; then
					mkdir "$m_meza/config/local-secret"
				fi

				# If environment doesn't already exist, create it
				if [ ! -d "$m_meza/config/local-secret/$3" ]; then

					# Copy the template environment
					cp -r "$m_meza/config/core/template/template-env/blank" "$m_meza/config/local-secret/$3"

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

					# Generate a random secret key
					wg_secret_key=$(cat /dev/urandom | tr -dc "a-zA-Z0-9" | fold -w 64 | head -n 1)

					sed -r -i "s/INSERT_FQDN/$fqdn/g;"                         "$m_meza/config/local-secret/$3/group_vars/all.yml"
					sed -r -i "s/INSERT_PRIVATE_ZONE/$private_net_zone/g;"     "$m_meza/config/local-secret/$3/group_vars/all.yml"
					sed -r -i "s/INSERT_ENABLE_EMAIL/$email/g;"                "$m_meza/config/local-secret/$3/group_vars/all.yml"
					sed -r -i "s/INSERT_SECRET_KEY/$wg_secret_key/g;"          "$m_meza/config/local-secret/$3/group_vars/all.yml"

					# All DB users used by the application (root, app, slave)
					# have the same password. Update as required.
					sed -r -i "s/INSERT_MYSQL_ROOT_PASS/$db_pass/g;"           "$m_meza/config/local-secret/$3/group_vars/all.yml"
					sed -r -i "s/INSERT_WIKI_APP_DB_USER_PASSWORD/$db_pass/g;" "$m_meza/config/local-secret/$3/group_vars/all.yml"
					sed -r -i "s/INSERT_SLAVE_PASSWORD/$db_pass/g;"            "$m_meza/config/local-secret/$3/group_vars/all.yml"

					# For monolith, make the IP/domain for every part of meza
					# be localhost. All other cases make user edit inventory
					# (AKA "hosts") file
					# NOTE: "INSERT_SLAVE" not in monolith list, so as not to
					#       configure the monolith as DB master _and_ slave
					if [ "$3" = "monolith" ]; then
						for part in INSERT_LB INSERT_APP INSERT_MEM INSERT_MASTER INSERT_PARSOID INSERT_ES INSERT_BACKUP; do
							sed -r -i "s/# $part/localhost/g;" "$m_meza/config/local-secret/$3/hosts"
						done
					else

						# If any of these variables are defined, put them into inventory file
						for INVENTORY_VARNAME in INSERT_LB INSERT_APP INSERT_MEM INSERT_MASTER INSERT_SLAVE INSERT_PARSOID INSERT_ES INSERT_BACKUP; do

							# Make INVENTORY_VALUE be the value of a variable with the name in INVENTORY_VARNAME
							# printf -v "${INVENTORY_VARNAME}" '%s' "${INVENTORY_VARNAME}"
							eval INVENTORY_VALUE="\$$INVENTORY_VARNAME"

							if [ ! -z "$INVENTORY_VALUE" ]; then
								# Excape value before doing sed-insertion
								INVENTORY_VALUE=$(echo "$INVENTORY_VALUE" | sed -e 's/[\/&]/\\&/g')
								sed -r -i "s/# $INVENTORY_VARNAME/$INVENTORY_VALUE/g;" "$m_meza/config/local-secret/$3/hosts"
							fi
						done

						echo
						echo "Please edit your inventory file to add or confirm the proper servers."
						echo "Run command:  sudo vi $m_meza/config/local-secret/$3/hosts"
					fi

				fi


				;;
			"dev")
				"$m_scripts/setup-dev.sh"
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
				host_file="/opt/meza/config/local-secret/$environment/hosts"

				# Get errors with user meza-ansible trying to write to the calling-user's
				# home directory if don't cd to a neutral location. FIXME.
				starting_wd=`pwd`
				cd /opt/meza/config/core

				if [ "$2" == "wiki-promptless" ]; then
					if [ -z "$4" ]; then echo "Please specify a wiki ID"; exit 1; fi
					if [ -z "$5" ]; then echo "Please specify a wiki name"; exit 1; fi
					playbook="create-wiki-promptless.yml"
					sudo -u meza-ansible ansible-playbook "/opt/meza/src/playbooks/$playbook" -i "$host_file" --extra-vars "env=$environment wiki_id=$4 wiki_name='$5'" ${@:6}
				else
					playbook="create-wiki.yml"
					sudo -u meza-ansible ansible-playbook "/opt/meza/src/playbooks/$playbook" -i "$host_file" --extra-vars "env=$environment" ${@:4}
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

	backup)

		if [ ! -z "$2" ]; then
			environment="$2"
		else
			echo
			echo "You must specify an environment: 'meza backup ENV'"
			exit 1;
		fi

		check_environment "$environment"
		host_file="/opt/meza/config/local-secret/$environment/hosts"

		# Get errors with user meza-ansible trying to write to the calling-user's
		# home directory if don't cd to a neutral location. FIXME.
		starting_wd=`pwd`
		cd /opt/meza/config/core
		sudo -u meza-ansible ansible-playbook "/opt/meza/src/playbooks/backup.yml" -i "$host_file" --extra-vars "env=$environment" ${@:3}
		cd "$starting_wd"
		exit 0;

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

		#
		# WARNING: THIS FUNCTION IS NOT USED ANYMORE AFAIK. IT WILL BE REMOVED
		# WHEN THAT IS CONFIRMED. FIXME.
		#

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

		#
		# WARNING: THIS FUNCTION IS NOT USED ANYMORE AFAIK. IT WILL BE REMOVED
		# WHEN THAT IS CONFIRMED. FIXME.
		#

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

		#
		# WARNING: THIS FUNCTION IS NOT USED ANYMORE AFAIK. IT WILL BE REMOVED
		# WHEN THAT IS CONFIRMED. FIXME.
		#

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

		#
		# WARNING: THIS FUNCTION IS NOT USED ANYMORE AFAIK. IT WILL BE REMOVED
		# WHEN THAT IS CONFIRMED. FIXME.
		#

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

		#
		# WARNING: THIS FUNCTION SHOULD STILL WORK ON MONOLITHS, BUT HAS NOT BE
		#          RE-TESTED SINCE MOVING TO ANSIBLE. FOR NON-MONOLITHS IT WILL
		#          NOT WORK AND NEEDS TO BE ANSIBLE-IZED. FIXME.
		#

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

	docker)
		case "$2" in
			"run")
				if [ -z "$3" ]; then
					docker_repo="jamesmontalvo3/meza-docker-test-max:latest"
				else
					docker_repo="$3"
				fi
				bash "$m_scripts/build-docker-container.sh" "$docker_repo"
				exit 0;
				;;
			"exec")
				if [ -z "$3" ]; then
					echo "Please provide docker container id"
					docker ps
					exit 1;
				else
					container_id="$3"
				fi

				if [ -z "$4" ]; then
					echo "Please supply a command for your container"
					exit 1;
				fi

				docker_exec=( docker exec --tty "$container_id" env TERM=xterm )
				${docker_exec[@]} ${@:4}
				;;
			*)
				echo "$2 not a valid command"
				exit 1;
				;;
		esac
		;;

	# not a valid command, show help and exit with error code
	*)
		cat "/opt/meza/manual/meza-command-help.txt"
		exit 1;
		;;

esac
