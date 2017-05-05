#!/bin/sh
#
# Script creates two containers:
#   1) A meza monolith, from a pre-built meza docker image
#   2) A backup server, from a base docker image, with non-standard setup
#

# -e: kill script if anything fails
# -u: don't allow undefined variables
# -x: debug mode; print executed commands
set -eux


# CONTAINER 1 is controller and monolith
container_name="ctrl"
source "$m_meza_host/tests/docker/init-controller.sh"
container_id_1="$container_id"
docker_ip_1="$docker_ip"
docker_exec_1=( "${docker_exec[@]}" )


# CONTAINER 2 is a backup server
container_name="bkup"
source "$m_meza_host/tests/docker/init-minion.sh"
docker_ip_2="$docker_ip"
docker_exec_2=( "${docker_exec[@]}" )


# CONTAINER 1
# (1) Get local secret config from repo
# (2) Change backup server IP address to docker#2 in hosts file
# (3) Change all other servers to docker#1 IP address in hosts file
# (4) Change FQDN to docker#1 IP address in group_vars/all.yml
${docker_exec_1[@]} git clone \
	https://github.com/enterprisemediawiki/meza-test-config-secret.git \
	"/opt/conf-meza/secret/$env_name"
${docker_exec_1[@]} sed -r -i "s/localhost #backup/$docker_ip_2/g;" \
	"/opt/conf-meza/secret/$env_name/hosts"
${docker_exec_1[@]} sed -r -i "s/localhost/$docker_ip_1/g;" \
	"/opt/conf-meza/secret/$env_name/hosts"
${docker_exec_1[@]} sed -r -i "s/INSERT_FQDN/$docker_ip_1/g;" \
	"/opt/conf-meza/secret/$env_name/group_vars/all.yml"
# Encrypted files won't play nice unless meza-ansible owns them
${docker_exec_1[@]} chown meza-ansible:wheel /opt/conf-meza/secret
${docker_exec_1[@]} chmod 640 /opt/conf-meza/secret


# CONTAINER 1
# Add to inventory file the "db-src" and "backups-src" groups (which will both
# be CONTAINER 2)
${docker_exec_1[@]} bash -c "echo -e '[backup-src]\n$docker_ip_2 alt_remote_user=test-user\n' >> /opt/conf-meza/secret/$env_name/hosts"
${docker_exec_1[@]} bash -c "echo -e '[exclude-all]\n$docker_ip_2\n' >> /opt/conf-meza/secret/$env_name/hosts"


${docker_exec_1[@]} bash -c "echo -e 'backups_src_uploads_path: /opt/alt/backups/<id>/uploads\n' >> /opt/conf-meza/secret/$env_name/group_vars/all.yml"
${docker_exec_1[@]} bash -c "echo -e 'backups_src_sql_path: /opt/alt/backups/<id>\n' >> /opt/conf-meza/secret/$env_name/group_vars/all.yml"


${docker_exec_1[@]} cat "/opt/conf-meza/secret/$env_name/hosts"


# CONTAINER 1: Put backup files/database on CONTAINER 2
# ${docker_exec_2[@]} git clone \
# 	https://github.com/jamesmontalvo3/meza-test-backups.git \
# 	"/opt/data-meza/backups/$env_name"
${docker_exec_1[@]} sudo -u meza-ansible ansible-playbook \
	/opt/meza/tests/deploys/setup-alt-source-backup.yml \
	-i "/opt/conf-meza/secret/$env_name/hosts" \
	--extra-vars "{\"env\":\"$env_name\"}"


# Run script on controller to `meza deploy`, `meza create wiki` and
# `meza backup`
${docker_exec_1[@]} bash /opt/meza/tests/deploys/import-from-remote.controller.sh "$env_name"


${docker_exec_1[@]} bash -c "echo -e 'db_src_mysql_user: root\n' >> /opt/conf-meza/secret/$env_name/group_vars/all.yml"
${docker_exec_1[@]} bash -c "echo -e 'db_src_mysql_pass: 1234\n' >> /opt/conf-meza/secret/$env_name/group_vars/all.yml"


# Add database source (e.g. pull direct from database) to inventory, make some
# modifications to database and uploaded files, then deploy with overwrite
${docker_exec_1[@]} bash -c "echo -e '[db-src]\n$docker_ip_2 alt_remote_user=test-user\n\n' >> /opt/conf-meza/secret/$env_name/hosts"
${docker_exec_1[@]} cat "/opt/conf-meza/secret/$env_name/hosts"
# garbage data into database and file uploads, just to check that the changes
# get copied to CONTAINER 1
${docker_exec_2[@]} mysql -u root -p1234 wiki_top -e"INSERT INTO watchlist (wl_user, wl_namespace, wl_title) VALUES (10000,0,'FAKE PAGE');"
${docker_exec_2[@]} bash -c "echo 'fake data' > /opt/alt/backups/top/uploads/fake.png"

#
# Re-deploy without --overwrite
#
${docker_exec_1[@]} meza deploy "$env_name" --tags "mediawiki" --skip-tags "latest"


#
# Do checks to make sure items NOT pulled from backups
#
${docker_exec_1[@]} mysql -e"SELECT * FROM wiki_top.watchlist WHERE wl_user = 10000;"
rows=$(docker exec $container_id_1 mysql -AN -e"SELECT COUNT(*) FROM wiki_top.watchlist WHERE wl_user = 10000;")
echo "${rows}"
if [ ${rows} -eq 0 ]; then
	echo "Row inserted into db-src server's database NOT FOUND in meza database AND SHOULD NOT BE"
else
	echo "Row inserted into db-src server's database IS PRESENT in meza database AND SHOULD NOT BE"
	exit 1
fi
${docker_exec_1[@]} ls /opt/data-meza/uploads
${docker_exec_1[@]} ls /opt/data-meza/uploads/top
${docker_exec_1[@]} cat /opt/data-meza/uploads/top/fake.png \
	&& (echo "fake.png present and should not be"; exit 1) \
	|| (echo "fake.png not present and should not be"; exit 0)


#
# Re-deploy with --overwrite
#
${docker_exec_1[@]} meza deploy "$env_name" --overwrite --tags "mediawiki" --skip-tags "latest"


#
# Do checks to make sure that new items pulled over with --overwrite
#
${docker_exec_1[@]} mysql -e"SELECT * FROM wiki_top.watchlist WHERE wl_user = 10000;"

rows=$(docker exec $container_id_1 mysql -AN -e"SELECT COUNT(*) FROM wiki_top.watchlist WHERE wl_user = 10000;")
echo "${rows}"

if [ ${rows} -gt 0 ]; then
	echo "Row inserted into db-src server's database IS PRESENT in meza database AND SHOULD BE"
else
	echo "Row inserted into db-src server's database NOT FOUND in meza database AND SHOULD BE"
	exit 1
fi

${docker_exec_1[@]} ls /opt/data-meza/uploads
${docker_exec_1[@]} ls /opt/data-meza/uploads/top
${docker_exec_1[@]} cat /opt/data-meza/uploads/top/fake.png
