#!/usr/bin/sh
#
# Enable mod_rewrite
#
# @todo: Try this mod_rewrite tester: http://htaccess.madewithlove.be/


cd /usr/local/apache2/conf
mv httpd.conf httpd.default.conf
cp ~/sources/meza1/client_files/config/httpd.conf ./httpd.conf

echo "restart apache httpd"
service httpd restart

cd /var/www/meza1/htdocs

echo "add .htaccess file to htdocs root"
cp ~/sources/meza1/client_files/root-htaccess ./.htaccess

echo "move wiki directory to mediawiki"
mv ./wiki ./mediawiki


echo "create \"wikis\" and \"__common\" directories"
mkdir ./wikis
mkdir ./__common




#
# Manual steps:
# 1) Update in LocalSettings.php: $wgScriptPath = "/eva";  (for example, for demonstration, still not farm)
# 2) Need to handle special LocalSettings, /images, logo, favicon
#
