#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
# thx to https://gist.github.com/bgallagh3r
#-------------------------------------------------------------------------------------------------------------

deinstall_wordpress() {
set -x

MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" ${SCRIPT_PATH}/login_information.txt)
WORDPRESS_DB_NAME=$(grep -Pom 1 "(?<=^WordpressDBName = ).*$" ${SCRIPT_PATH}/wordpress_login_data.txt)
WordpressDBUser=$(grep -Pom 1 "(?<=^WordpressDBUser = ).*$" ${SCRIPT_PATH}/wordpress_login_data.txt)
WordpressScriptPath=$(grep -Pom 1 "(?<=^WordpressScriptPath = ).*$" ${SCRIPT_PATH}/wordpress_login_data.txt)

mysql -u root -p${MYSQL_ROOT_PASS} -e "DROP DATABASE IF EXISTS ${WORDPRESS_DB_NAME};"
mysql -u root -p${MYSQL_ROOT_PASS} -e "DROP USER ${WordpressDBUser}@localhost;"

rm -rf /var/www/${MYDOMAIN}/public/${WordpressScriptPath}
#https://github.com/shoujii/NeXt-Server/issues/47
rm ${SCRIPT_PATH}/wordpress_login_data.txt

service nginx restart
}
