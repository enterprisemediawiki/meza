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
