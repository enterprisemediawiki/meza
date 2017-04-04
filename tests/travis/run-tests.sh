#!/bin/bash
#
#

# Report docker version just in case we run into issues in the future, and we
# want to be able to track how things have changed
docker -v


if [ "$test_type" == "monolith-from-scratch" ]; then

	# Working directory in Travis is the GitHub repo, which is meza. Mount it.
	source ./tests/travis/init-container.sh "${PWD}" "mount"

	${docker_exec[@]} bash /opt/meza/tests/travis/monolith-from-scratch.sh "$docker_ip"

elif [ "$test_type" == "monolith-from-import" ]; then

	# Working directory in Travis is the GitHub repo, which is meza. Mount it.
	source ./tests/travis/init-container.sh "${PWD}" "mount"

	# TEST ANSIBLE SYNTAX. FIXME: syntax check all playbooks
	${docker_exec[@]} ANSIBLE_CONFIG=/opt/meza/config/core/ansible.cfg ansible-playbook /opt/meza/src/playbooks/site.yml --syntax-check

	${docker_exec[@]} bash /opt/meza/tests/travis/monolith-from-import.sh "$docker_ip"

elif [ "$test_type" == "import-from-remote" ]; then

	m_meza_host="${PWD}"
	env_name=travis
	source ./tests/travis/import-from-remote.setup.sh

elif [ "$test_type" == "backup-to-remote" ]; then

	m_meza_host="${PWD}"
	env_name=travis
	source ./tests/travis/backup-to-remote.setup.sh

else
	echo "Bad test type: $test_type"
	exit 1
fi
