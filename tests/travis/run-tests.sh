#!/bin/bash
#
#

# Report docker version just in case we run into issues in the future, and we
# want to be able to track how things have changed
docker -v


if [ "$test_type" == "monolith_from_scratch" ]; then

	# Working directory in Travis is the GitHub repo, which is meza. Mount it.
	source ./tests/travis/init-container.sh "${PWD}" "mount"

	${docker_exec[@]} bash /opt/meza/tests/travis/monolith-from-scratch.sh "$docker_ip"

elif [ "$test_type" == "monolith_from_import" ]; then

	# Working directory in Travis is the GitHub repo, which is meza. Mount it.
	source ./tests/travis/init-container.sh "${PWD}" "mount"

	# TEST ANSIBLE SYNTAX. FIXME: syntax check all playbooks
	${docker_exec[@]} ANSIBLE_CONFIG=/opt/meza/config/core/ansible.cfg ansible-playbook /opt/meza/src/playbooks/site.yml --syntax-check

	${docker_exec[@]} bash /opt/meza/tests/travis/monolith-from-import.sh "$docker_ip"

elif [ "$test_type" == "two_containers" ]; then

	# Working directory in Travis is the GitHub repo, which is meza. Mount it.
	source ./tests/travis/init-container.sh "${PWD}" "mount"

	# Get vars and copy the docker exec command from first container
	container_id_1="$container_id"
	docker_ip_1="$docker_ip"
	docker_exec_1=( "${docker_exec[@]}" )

	echo
	echo "First container id: $container_id_1"
	echo "First container IP address: $docker_ip_1"
	echo

	# Create a second container that needs to git-clone meza and checkout the
	# same commit as Travis already has
	source ./tests/travis/init-container.sh "${PWD}" "copy"

	# Get vars and copy the docker exec command
	container_id_2="$container_id"
	docker_ip_2="$docker_ip"
	docker_exec_2=( "${docker_exec[@]}" )

	echo
	echo "Second container id: $container_id_2"
	echo "Second container IP address: $docker_ip_2"
	echo

	# Note: both of these git commands should be replaced by `meza --version`
	#       but that is having issues as of this time (Issue #527)
	${docker_exec_1[@]} git --git-dir=/opt/meza/.git rev-parse HEAD
	${docker_exec_2[@]} git --git-dir=/opt/meza/.git rev-parse HEAD

elif [ "$test_type" == "docker_preinstall" ]; then

	docker_repo="jamesmontalvo3/meza-docker-full:latest"

	# Working directory in Travis is the GitHub repo, which is meza. Mount it.
	source ./tests/travis/init-container.sh "none"

	${docker_exec[@]} bash /opt/meza/tests/travis/git-setup.sh "$TRAVIS_EVENT_TYPE" \
		"$TRAVIS_COMMIT" "$TRAVIS_PULL_REQUEST_SHA" "$TRAVIS_BRANCH" "$TRAVIS_PULL_REQUEST_BRANCH"

	${docker_exec[@]} bash /opt/meza/tests/travis/monolith-from-preinstall.sh "$docker_ip"

else
	echo "Bad test type: $test_type"
	exit 1
fi
