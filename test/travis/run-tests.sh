#!/bin/bash
#
#

# SETUP CONTAINER
source /opt/meza/test/travis/setup-container.sh

# Install meza command
${docker_exec[@]} bash /opt/meza/scripts/getmeza.sh

if [ "$test_type" == "monolith_from_scratch" ]; then

	# TEST ANSIBLE SYNTAX. FIXME: syntax check all playbooks
	${docker_exec[@]} ansible-playbook /opt/meza/ansible/site.yml --syntax-check

	# Since we want to make the monolith environment without prompts, need to do
	# `meza setup env monolith` with values for required args included (fqdn,
	# db_pass, email, private_net_zone).
	${docker_exec[@]} fqdn=${docker_ip} db_pass=1234 email=false private_net_zone=public meza setup env monolith

	# Now that environment monolith is setup, deploy/install it
	${docker_exec[@]} meza install monolith

	# TEST BASIC SYSTEM FUNCTIONALITY
	source /opt/meza/test/server-check.sh

	# Demo Wiki API test
	bash /opt/meza/test/wiki-check.sh "demo" "Demo Wiki" "$container_id"

	# FIXME: TEST FOR IDEMPOTENCE. THIS WILL FAIL CURRENTLY.

	# CREATE WIKI AND TEST
	${docker_exec[@]} meza create wiki-promptless monolith created "Created Wiki"

	# Created Wiki API test
	bash /opt/meza/test/wiki-check.sh "created" "Created Wiki" "$container_id"

elif [ "$test_type" == "monolith_from_import" ]; then

	# Get test "secret" config
	${docker_exec[@]} git clone https://github.com/enterprisemediawiki/meza-test-config-secret.git /opt/meza/ansible/env/imported

	# Write the docker containers IP as the FQDN for the test config (the only
	# config setting we can't know ahead of time)
	sed -r -i "s/INSERT_FQDN/$docker_ip/g;" "$m_meza/ansible/env/imported/group_vars/all.yml"

	# Get test non-secret config
	${docker_exec[@]} git clone https://github.com/enterprisemediawiki/meza-test-config.git /opt/meza/config/local_control

	# FIXME: get backup files for test

	# Deploy "imported" environment with test config
	${docker_exec[@]} meza install imported

	# Basic system check
	source /opt/meza/test/server-check.sh

	# Top Wiki API test
	bash /opt/meza/test/wiki-check.sh "top" "Top Wiki" "$container_id"

else
	echo "Bad test type: $test_type"
	exit 1
fi
