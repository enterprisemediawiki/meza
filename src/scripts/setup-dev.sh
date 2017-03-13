#!/bin/sh
#
# Setup dev stuff for meza

# Load config constants. Unfortunately right now have to write out full path to
# meza since we can't be certain of consistent method of accessing install.sh.
source "/opt/meza/config/core/config.sh"

source "$m_scripts/shell-functions/base.sh"
rootCheck

# This will be re-sourced after prompts to get modified config
touch "$m_local_config_file"
source "$m_local_config_file"

# i18n message file
source "$m_i18n/$m_language.sh"

meza prompt "dev_users" "$MSG_prompt_dev_users"
meza prompt "dev_git_user" "$MSG_prompt_dev_git_user"
meza prompt "dev_git_user_email" "$MSG_prompt_dev_git_user_email"

# Reload config file after prompts
source "$m_local_config_file"


for dev_user in $dev_users; do

	sudo -u "$dev_user" git config --global user.name "$dev_git_user"
	sudo -u "$dev_user" git config --global user.email "$dev_git_user_email"
	sudo -u "$dev_user" git config --global color.ui true

done

# ref: https://www.liquidweb.com/kb/how-to-install-and-configure-vsftpd-on-centos-7/
yum -y install vsftpd
sed -r -i 's/anonymous_enable=YES/anonymous_enable=NO/g;' /etc/vsftpd/vsftpd.conf
sed -r -i 's/local_enable=NO/local_enable=YES/g;' /etc/vsftpd/vsftpd.conf
sed -r -i 's/write_enable=NO/write_enable=YES/g;' /etc/vsftpd/vsftpd.conf

# Start FTP and setup firewall
systemctl restart vsftpd
systemctl enable vsftpd
firewall-cmd --permanent --add-port=21/tcp
firewall-cmd --reload


echo "To setup SFTP in Sublime Text, see:"
echo "https://wbond.net/sublime_packages/sftp/settings#Remote_Server_Settings"
