#!/bin/sh
#
# Run tests for basic server functionality

# -e: kill script if anything fails
# -u: don't allow undefined variables
# -x: debug mode; print executed commands
set -eux

# Ensure Node.js, PHP, MariaDB installed
which node
node -v
which php
php --version
which mysql
mysql --version

curl_args=( curl --write-out %{http_code} --silent --output /dev/null )


# HAProxy 302 redirect test
${curl_args[@]} http://127.0.0.1

${curl_args[@]} http://127.0.0.1 \
	| grep -q '302' \
	&& (echo 'HAProxy 302 redirect test: pass' && exit 0) \
	|| (echo 'HAProxy 302 redirect test: fail' && exit 1)

# Apache (over port 8080) 200 OK test
${curl_args[@]} http://127.0.0.1:8080

${curl_args[@]} http://127.0.0.1:8080 \
	| grep -q '200' \
	&& (echo 'Apache 200 test: pass' && exit 0) \
	|| (echo 'Apache 200 test: fail' && exit 1)

# Parsoid check
${curl_args[@]} http://127.0.0.1:8000

${curl_args[@]} http://127.0.0.1:8000 \
	| grep -q '200' \
	&& (echo 'Parsoid 200 test: pass' && exit 0) \
	|| (echo 'Parsoid 200 test: fail' && exit 1)

