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

if [ ! -d "$m_meza_host/.git" ]; then
	"$m_meza_host is not a git repository"
	exit 1;
fi

# This is required so Docker containers can get the appropriate version. It
# would be better if containers shared a volume with the meza application to
# ensure getting the correct version, but for now that is not possible due to
# the /opt/meza directory also containing data, the MediaWiki application,
# configuration, etc, which would be overwritten by the volume if the specific
# container had pre-loaded them.
if [ -z "$TRAVIS_EVENT_TYPE" ]; then
	# Emulate some travis environment variables.
	export TRAVIS_EVENT_TYPE="push"
	export TRAVIS_COMMIT=$(git --git-dir=/opt/meza/.git rev-parse HEAD)

	echo "Using version $TRAVIS_COMMIT"

	# None of these should be required provided TRAVIS_EVENT_TYPE=push, but they
	# can't be unset.
	TRAVIS_PULL_REQUEST_SHA=""
	TRAVIS_BRANCH=""
	TRAVIS_PULL_REQUEST_BRANCH=""
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
	${docker_exec[@]} ANSIBLE_CONFIG=/opt/meza/config/core/ansible.cfg ansible-playbook /opt/meza/src/playbooks/site.yml --syntax-check

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
