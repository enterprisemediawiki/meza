#!/bin/bash
#
#


if [ -z "$1" ]; then
	echo "Please provide wiki_id to test"
	exit 1
else
	wiki_id="$1"
fi

if [ -z "$2" ]; then
	echo "Please provide wiki_name to test"
	exit 1
else
	wiki_name="$2"
fi

if [ -z "$3" ]; then
	echo "Please provide Docker container_id to test"
	exit 1
else
	container_id="$3"
fi

source "/opt/meza/test/travis/variables.sh"

# Wiki API test
api_url="http://127.0.0.1:8080/$wiki_id/api.php?action=query&meta=siteinfo&format=json"
${docker_exec[@]} curl -L "$api_url"

${docker_exec[@]} curl -L "$api_url" \
    | grep -q '"sitename":"$wiki_name",' \
    && (echo '$wiki_name API test: pass' && exit 0) \
    || (echo '$wiki_name API test: fail' && exit 1)

