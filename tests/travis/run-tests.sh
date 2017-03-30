#!/bin/bash
#
#

# Report docker version just in case we run into issues in the future, and we
# want to be able to track how things have changed
docker -v

# Working directory in Travis is the GitHub repo, which is meza. Mount it.
host_mount_dir="${PWD}"
source /opt/meza/tests/travis/init-container.sh

# Get IP of docker image
docker_ip=$(docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" "$container_id")

if [ "$test_type" == "monolith_from_scratch" ]; then

	${docker_exec[@]} bash /opt/meza/tests/travis/monolith-from-scratch.sh "$docker_ip"

elif [ "$test_type" == "monolith_from_import" ]; then

	# TEST ANSIBLE SYNTAX. FIXME: syntax check all playbooks
	${docker_exec[@]} ANSIBLE_CONFIG=/opt/meza/config/core/ansible.cfg ansible-playbook /opt/meza/src/playbooks/site.yml --syntax-check

	${docker_exec[@]} bash /opt/meza/tests/travis/monolith-from-import.sh "$docker_ip"

else
	echo "Bad test type: $test_type"
	exit 1
fi
