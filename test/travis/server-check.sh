#!/bin/bash
#
#

# Ensure Node.js, PHP, MariaDB installed
${docker_exec[@]} which node
${docker_exec[@]} node -v
${docker_exec[@]} which php
${docker_exec[@]} php --version
${docker_exec[@]} which mysql
${docker_exec[@]} mysql --version


# HAProxy 302 redirect test
${docker_exec[@]} ${curl_args[@]} http://127.0.0.1

${docker_exec[@]} ${curl_args[@]} http://127.0.0.1 \
	| grep -q '302' \
	&& (echo 'HAProxy 302 redirect test: pass' && exit 0) \
	|| (echo 'HAProxy 302 redirect test: fail' && exit 1)

# Apache (over port 8080) 200 OK test
${docker_exec[@]} ${curl_args[@]} http://127.0.0.1:8080

${docker_exec[@]} ${curl_args[@]} http://127.0.0.1:8080 \
	| grep -q '200' \
	&& (echo 'Apache 200 test: pass' && exit 0) \
	|| (echo 'Apache 200 test: fail' && exit 1)
