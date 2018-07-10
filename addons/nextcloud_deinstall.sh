#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
# thx to https://gist.github.com/bgallagh3r
#-------------------------------------------------------------------------------------------------------------

deinstall_nextcloud() {

MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" ${SCRIPT_PATH}/login_information.txt)
NextcloudDBName=$(grep -Pom 1 "(?<=^NextcloudDBName = ).*$" ${SCRIPT_PATH}/nextcloud_login_data.txt)
NextcloudDBUser=$(grep -Pom 1 "(?<=^NextcloudDBUser = ).*$" ${SCRIPT_PATH}/nextcloud_login_data.txt)

mysql -u root -p${MYSQL_ROOT_PASS} -e "DROP DATABASE IF EXISTS ${NextcloudDBName};"
mysql -u root -p${MYSQL_ROOT_PASS} -e "DROP USER ${NextcloudDBName}@localhost;"

rm -rf /var/www/${MYDOMAIN}/public/nextcloud
#https://github.com/shoujii/NeXt-Server/issues/47
rm ${SCRIPT_PATH}/nextcloud_login_data.txt
sed -i "s/include _nextcloud.conf;/#include _nextcloud.conf;/g" /etc/nginx/sites-available/${MYDOMAIN}.conf

service nginx restart
}
