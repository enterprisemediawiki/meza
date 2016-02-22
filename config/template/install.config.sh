#!/bin/bash
#
# File to setup install.sh without using prompts

git_branch="master"

usergithubtoken="e9191bc6d394d64011273d19f4c6be47eb10e25b"

mysql_root_pass="testpass"

mw_api_domain="192.168.56.56"

mediawiki_git_install="y"

openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=US/ST=TX/L=Houston/O=EnterpriseMediaWiki/CN=enterprisemediawiki.org" \
    -keyout /etc/pki/tls/private/meza.key -out /etc/pki/tls/certs/meza.crt

slackwebhook="n"
