#!/usr/bin/sh
#
# Enable mod_rewrite



cd /usr/local/apache2/conf
mv httpd.conf httpd.old.conf
cp ~/sources/meza1/client_files/config/httpd.conf ./httpd.conf

echo "restart apache httpd"
service httpd restart

echo "add .htaccess file to htdocs root"
cp ~/sources/meza1/client_files/root-htaccess /var/www/meza1/htdocs/.htaccess

#
# Manual steps:
# 1) Update in LocalSettings.php: $wgScriptPath = "/eva";  (for example, for demonstration, still not farm)
# 2) Need to handle special LocalSettings, /images, logo, favicon
#