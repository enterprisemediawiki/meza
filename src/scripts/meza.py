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
	command = ['sudo', '-u', 'meza-ansible', 'ansible-playbook',
		'/opt/meza/src/playbooks/{}.yml'.format(playbook)]
	if env:
		host_file = "/opt/meza/config/local-secret/{}/hosts".format(env)
		command = command + [ '-i', host_file, "--extra-vars", "env="+env ]
	return command

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



# env
# dev
# dev-networking --> vbox-networking ??
# docker
def meza_command_setup (argv):

	sub_command = argv[0]
	if sub_command == "dev-networking":
		sub_command = "dev_networking" # hyphen not a valid function character
	command_fn = "meza_command_setup_" + argv[0]

	# if command_fn is a valid Python function, pass it all remaining args
	if command_fn in locals() and callable( locals()[command_fn] ):
		locals()[command_fn]( argv[1:] )
	else:
		print
		print sub_command + " is not a valid sub-command for setup"
		sys.exit(1)

def meza_command_setup_env (argv):

	if len(argv) == 0:
		print
		print "Please include a valid environment name"
		sys.exit(1)

	env = argv[0]

	# if not os.path.isdir( "/opt/meza/config/local-secret" ):
	# 	os.mkdir( "/opt/meza/config/local-secret" )

	if os.path.isdir( "/opt/meza/config/local-secret/" + env ):
		print
		print "Environment {} already exists".format(env)
		sys.exit(1)



	# Copy the template environment
	# cp( "/opt/meza/config/core/template/template-env/blank", "/opt/meza/config/local-secret/" + env )


	# --fqdn=
	# --db_pass=
	# --enable_email=
	# --private_net_zone=
	inputfile = ''
	outputfile = ''
	try:
		opts, args = getopt.getopt(argv,"h",["help","fqdn=","db_pass=","enable_email=","private_net_zone="])
	except getopt.GetoptError:
		print 'meza setup env <env> [options]'
		sys.exit(1)
	for opt, arg in opts:
		if opt in ("-h", "--help"):
			# FIXME: better help
			print 'meza setup env <env> [options]'
			sys.exit(0)
		elif opt == "--fqdn":
			fqdn = arg
		elif opt == "--db_pass":
			# This will put the DB password on the command line, so should
			# only be done in testing cases
			db_pass = arg
		elif opt == "--enable_email":
			enable_email = arg
		elif opt == "--private_net_zone":
			private_net_zone = arg
		else:
			print "Unrecognized option " + opt
			sys.exit(1)

	if not fqdn:
		fqdn = prompt("fqdn")

	if not db_pass:
		db_pass = prompt_secure("db_pass")

	if not enable_email:
		enable_email = prompt("enable_email")

	# No need for private networking. Set to public.
	if env == "monolith":
		private_net_zone = "public"

		# list of servers
		load_balancers = app_servers = memcached_servers = parsoid_servers = elastic_servers = backup_servers = ['localhost']
		db_slaves = [] # None on a monolith
		db_master = 'localhost' # single server, e.g. just a string


	else:
		# list of servers
		load_balancers = app_servers = memcached_servers = db_slaves = parsoid_servers = elastic_servers = backup_servers = ['# INSERT']

		# single server, e.g. just a string
		db_master = '# INSERT'


	if not private_net_zone:
		private_net_zone = prompt("private_net_zone")

	import json
	env_vars = json.dumps({
		'env': env,

		'fqdn': fqdn,
		'enable_email': enable_email,
		'private_net_zone': private_net_zone,

		# Set all db passwords the same
		'mysql_root_pass': db_pass,
		'wiki_app_db_pass': db_pass,
		'db_slave_pass': db_pass,

		# Generate a random secret key
		'wg_secret_key': random_string( num_chars=64, valid_chars= string.ascii_letters + string.digits ),

		# Lists of servers
		'load_balancers': load_balancers,
		'app_servers': app_servers,
		'memcached_servers': memcached_servers,
		'db_slaves': db_slaves,
		'parsoid_servers': parsoid_servers,
		'elastic_servers': elastic_servers,
		'backup_servers': backup_servers,

		# Single server
		'db_master': db_master
	})


	shell_cmd = playbook_cmd( "setup-env" ) + ["--extra-vars", env_vars]
	return_code = meza_shell_exec( shell_cmd )

	print
	print "Please review your config files. Run commands:"
	print "  sudo vi /opt/meza/config/local-secret/{}/hosts".format(env)
	print "  sudo vi /opt/meza/config/local-secret/{}/group_vars/all.yml".format(env)
	sys.exit(0)

def meza_command_setup_dev (argv):
	source "$m_scripts/setup-dev.sh"

def meza_command_setup_dev_networking (argv):
	???

def meza_command_setup_docker (argv):
	???

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



# http://stackoverflow.com/questions/1994488/copy-file-or-directories-recursively-in-python
def copy (src, dst):
	import shutil, errno

    try:
        shutil.copytree(src, dst)
    except OSError as exc: # python >2.5
        if exc.errno == errno.ENOTDIR:
            shutil.copy(src, dst)
        else: raise


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

