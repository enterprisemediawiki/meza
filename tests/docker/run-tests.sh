#!/bin/bash
#
# Run tests intended for Travis in local Docker containers

# -e: kill script if anything fails
# -u: don't allow undefined variables
set -eu

test_type="$1"
m_meza_host="/opt/meza"

# Emulate some travis environment variables.
export TRAVIS_EVENT_TYPE="push"
export TRAVIS_COMMIT=$(git --git-dir=/opt/meza/.git rev-parse HEAD)

# None of these should be required provided TRAVIS_EVENT_TYPE=push
# TRAVIS_PULL_REQUEST_SHA
# TRAVIS_BRANCH
# TRAVIS_PULL_REQUEST_BRANCH


if [ "$test_type" == "monolith-from-scratch" ]; then

	# Working directory in Travis is the GitHub repo, which is meza. Mount it.
	source "$m_meza_host/tests/travis/init-container.sh" "${m_meza_host}" "mount"

	${docker_exec[@]} bash /opt/meza/tests/travis/monolith-from-scratch.sh "$docker_ip"

elif [ "$test_type" == "monolith-from-import" ]; then

	# Working directory in Travis is the GitHub repo, which is meza. Mount it.
	source "$m_meza_host/tests/travis/init-container.sh" "${m_meza_host}" "mount"

	# TEST ANSIBLE SYNTAX. FIXME: syntax check all playbooks
	${docker_exec[@]} ANSIBLE_CONFIG=/opt/meza/config/core/ansible.cfg ansible-playbook /opt/meza/src/playbooks/site.yml --syntax-check

	${docker_exec[@]} bash /opt/meza/tests/travis/monolith-from-import.sh "$docker_ip"

elif [ "$test_type" == "import-from-remote" ]; then

	env_name=travis
	source "$m_meza_host/tests/travis/import-from-remote.setup.sh"

elif [ "$test_type" == "backup-to-remote" ]; then

	env_name=travis
	source "$m_meza_host/tests/travis/backup-to-remote.setup.sh"

else
	echo "Bad test type: $test_type"
	exit 1
fi
