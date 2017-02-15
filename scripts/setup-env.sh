#!/bin/bash
#
# Build meza ansible environment


echo
echo "Choose a short, one-word name for the environment"
echo "(examples: prod, test, staging, dev)"
while [ -z "$environment" ]; do
	read -e environment
	echo

	if ! [[ $environment =~ ^[a-zA-Z0-9]+$ ]]; then
		echo "Name \"$environment\" invalid."
		echo "Only alphanumeric characters. No spaces. Try again."
		environment=""
	fi
done

echo "Environment set to \"$environment\""
env_dir="/opt/meza/ansible/env/$environment"
if [ -d "$env_dir" ]; then
	echo
	echo "Environment $environment already exists. Exiting."
	exit 1
fi

echo
echo "Enter the domains or IP addresses of app servers, separated"
echo "by spaces. Leave blank for default \"localhost\""
read -e app_servers

if [ -z "$app_servers" ]; then
	app_servers="localhost"
fi

echo "App servers set to \"$app_servers\""

echo
echo "Enter the domain or IP address of the master database server"
echo "or leave blank for default \"localhost\""
while [ -z "$db_master" ]; do
	read -e db_master
done

if [ -z "$db_master" ]; then
	db_master="localhost"
fi

echo "Database master set to \"$db_master\""


echo
echo "Enter the domains or IP addresses of replica database"
echo "servers, separated by spaces. Leave blank for no replicas."
read -e db_slaves





echo
echo "Enter the domains or IP addresses of parsoid servers,"
echo "separated by spaces. Leave blank for default \"localhost\""
read -e parsoid_servers

if [ -z "$parsoid_servers" ]; then
	parsoid_servers="localhost"
fi

echo "Parsoid servers set to \"$parsoid_servers\""



echo
echo "Enter the domains or IP addresses of Elasticsearch servers,"
echo "separated by spaces. Leave blank for default \"localhost\""
read -e elastic_servers

if [ -z "$elastic_servers" ]; then
	elastic_servers="localhost"
fi

echo "Elasticsearch servers set to \"$elastic_servers\""


# spaces to newlines
app_servers=`echo "$app_servers" | tr -s ' ' "\n"`
parsoid_servers=`echo "$parsoid_servers" | tr -s ' ' "\n"`
elastic_servers=`echo "$elastic_servers" | tr -s ' ' "\n"`

slave_servers=""
db_server_id=1
for db_slave in $db_slaves; do
	# slave server id must be 2 or higher (master = 1)
	((db_server_id++))
	slave_servers="$slave_servers\n$db_slave mysql_server_id=$db_server_id"
done

hosts_file=`cat /opt/meza/scripts/make-environment/hosts.default`
hosts_file=echo "$hosts_file" | sed "s/APP_SERVERS/$app_servers/"
hosts_file=echo "$hosts_file" | sed "s/DB_MASTER/$db_master/"
hosts_file=echo "$hosts_file" | sed "s/DB_SLAVES/$slave_servers/"
hosts_file=echo "$hosts_file" | sed "s/PARSOID_SERVERS/$parsoid_servers/"
hosts_file=echo "$hosts_file" | sed "s/ELASTIC_SERVERS/$elastic_servers/"

echo "$hosts_file" > "$env_dir/hosts"

mkdir "$env_dir/group_vars"




---

env: ENVIRONMENT

# Users absolutely should override this. FIXME: should we not make this default?
m_private_networking_zone: public


# Domain that the wiki server is accessed from. This is used by Apache's config
# to do HTTP-->HTTPS redirect and by Parsoid to communicate with the MediaWiki
# PHP API via Apache httpd over port 9000. Note: protocol was $mw_api_protocol,
# but was changed to hard-coded http when Parsoid was given it's own port.
mw_api_domain: 192.168.56.63


# Password for mysql root user
mysql_root_password: 4321


wiki_app_db_user:
  name: wiki_app_user
  password: wiki_app_user_password
  priv: "*.*:ALL"

# List of users. Currently only wiki_app_user is required. This should perhaps
# be handled in such a way that it's not possible to remove wiki_app_user, and
# then this mysql_users list would just be for additional users (e.g. humans
# who want to query the database). Alternatively, this would be easy to create
# separate users for each wiki (which I've heard can have performance benefits)
mysql_users: []
  # - name: "james"
  #   host: "%"
  #   password: "mypassword"
  #   priv: "*.*:ALL"

# User on database master that slaves use perform replication
mysql_replication_user:
  name: "db_slave_user"
  password: "db_slave_user_password"

# Set in secure/secure.yml on an instance basis
# m_wiki_app_user: wiki_app_user
# m_wiki_app_user_password: 12345678
# m_db_slave_user: db_slave_user
# m_db_slave_user_password: 12345678

enable_wiki_emails: true

