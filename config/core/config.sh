#!/bin/bash


#
# Path configuration
#

# meza install location
m_install=/opt # was :m_install=/root/mezadownloads
m_meza="$m_install/meza" # was: m_meza="$m_install/meza1"

m_logs=/opt/meza/data/logs

# config dir
m_config="$m_meza/config"
m_local_app="/opt/meza/config/local_app"

# scripts dir
m_scripts="$m_meza/src/scripts"

# test dir
m_test="$m_meza/test"

# webserver variables
m_htdocs="$m_meza/htdocs" # was: m_htdocs="$m_www_meza/htdocs"
m_mediawiki="$m_htdocs/mediawiki"

# app locations
m_apache="/etc/httpd"

# files
m_i18n="$m_config/core/i18n"
m_db_replication_dump_file="/opt/meza/data/db_master_for_replication.sql"
m_db_replication_log_file="/opt/meza/data/db_master_log_file"
m_db_replication_log_pos="/opt/meza/data/db_master_log_pos"

# FIXME: This needs to be handled another way
m_local_config_file="$m_config/config.local.sh"


#
# Installation configuration
#

# Install MediaWiki with git. Faster without it, but we seem to want to stick with doing it via git
mediawiki_git_install="y"

# GitHub API personal access token for Oscar Rogers
# If you run this script multiple times from one IP address, you might exceed
# GitHub's API rate limit. Below is enterprisemediawiki/meza's generic token
# for general use. However, if this project gets used a lot by any people it
# the rate limit for it could be overriden as well. Setup your own token at
# https://github.com/settings/tokens to generate a new token.
usergithubtoken=e9191bc6d394d64011273d19f4c6be47eb10e25b

# Set Parsoid version.
# This should be able to be set in any of these forms:
#   9260e5d       (a sha1 hash)
#   tags/v0.4.1   (a tag name)
#   master        (a branch name)
parsoid_version="dd8e644d320aec076f76da4e2bd70a8527e0dfd8" # closest to MW 1.27 release date of 28 June 2016

# Announce completion on Slack? Enter webhook URI.
slackwebhook="n"

# Get server architecture here so other scripts don't have to figure it out
if [ $(uname -m | grep -c 64) -eq 1 ]; then
    m_architecture=64 # 64-bit
else
    m_architecture=32 # 32-bit
fi

m_wiki_app_user="wiki_app_user"
m_db_slave_user="db_slave_user"
m_language="en"

# Users absolutely should override this. FIXME: should we not make this default?
m_private_networking_zone="public"

# Ansible
ansible_user="meza-ansible"
