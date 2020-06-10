#!/bin/bash
#

# Report docker version just in case we run into issues in the future, and we
# want to be able to track how things have changed. This is mostly intended for
# Travis.
docker -v


if [ ! -z "$2" ]; then
	m_meza_host="$2"
else
	m_meza_host="/opt/meza"
fi

# -e: kill script if anything fails
# -u: don't allow undefined variables
set -eu

test_type="$1"

if [ "$test_type" == "monolith-from-scratch" ]; then

	# Working directory in Travis is the GitHub repo, which is meza. Mount it.
	source "$m_meza_host/tests/docker/init-container.sh" "${m_meza_host}" "mount"

	${docker_exec[@]} bash /opt/meza/tests/deploys/monolith-from-scratch.controller.sh "$docker_ip"

elif [ "$test_type" == "monolith-from-import" ]; then

	# Working directory in Travis is the GitHub repo, which is meza. Mount it.
	source "$m_meza_host/tests/docker/init-container.sh" "${m_meza_host}" "mount"

	# Test Ansible syntax
	# FIXME #829: syntax check all playbooks
	${docker_exec[@]} ANSIBLE_CONFIG=/opt/meza/config/ansible.cfg ansible-playbook /opt/meza/src/playbooks/site.yml --syntax-check

	${docker_exec[@]} bash /opt/meza/tests/deploys/monolith-from-import.controller.sh "$docker_ip"

elif [ "$test_type" == "import-from-remote" ]; then

	env_name=travis
	source "$m_meza_host/tests/docker/import-from-remote.setup.sh"

elif [ "$test_type" == "backup-to-remote" ]; then

	env_name=travis
	source "$m_meza_host/tests/docker/backup-to-remote.setup.sh"

elif [ "$test_type" == "import-from-alt-remote" ]; then

	env_name=travis
	source "$m_meza_host/tests/docker/import-from-alt-remote.setup.sh"

else
	echo "Bad test type: $test_type"
	exit 1
fi
