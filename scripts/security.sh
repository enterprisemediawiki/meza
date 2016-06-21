#!/bin/sh
#
# Script used by install.sh to cover finalizing the security configuration
# for anything that didn't logically get handled in a prior script

# Limit ciphers and MAC algorithms used for SSH.
# FIXME: make this check for existing rules for these, or give option not to
#        apply these rules. See issue #390
cat "$m_config/template/ssh" >> /etc/ssh/ssh_config
cat "$m_config/template/ssh" >> /etc/ssh/sshd_config
service sshd restart
