#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
# thx to https://gist.github.com/bgallagh3r
#-------------------------------------------------------------------------------------------------------------

deinstall_wordpress() {
set -x
rm -rf /etc/nginx/html/wordpress

MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" /root/NeXt-Server/login_information.txt)
WORDPRESS_DB_NAME=$(grep -Pom 1 "(?<=^WordpressDBName = ).*$" /root/NeXt-Server/login_information.txt)
WordpressDBUser=$(grep -Pom 1 "(?<=^WordpressDBUser = ).*$" /root/NeXt-Server/login_information.txt)
WordpressScriptPath=$(grep -Pom 1 "(?<=^WordpressScriptPath = ).*$" /root/NeXt-Server/login_information.txt)


mysql -u root -p${MYSQL_ROOT_PASS} -e "DROP DATABASE IF EXISTS ${WORDPRESS_DB_NAME};"
mysql -u root -p${MYSQL_ROOT_PASS} -e "DROP USER ${WordpressDBUser}@localhost;"
rm -rf /etc/nginx/html/${WordpressScriptPath}
rm -rf /etc/nginx/sites-custom/wordpress.conf

mkdir /etc/nginx/html/${MYDOMAIN}
cp ${SCRIPT_PATH}/NeXt-logo.jpg /etc/nginx/html/${MYDOMAIN}/
cp ${SCRIPT_PATH}/configs/nginx/index.html /etc/nginx/html/${MYDOMAIN}/index.html

}
