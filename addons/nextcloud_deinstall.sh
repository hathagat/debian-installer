#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
# thx to https://gist.github.com/bgallagh3r
#-------------------------------------------------------------------------------------------------------------

deinstall_nextcloud() {

trap error_exit ERR

MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" ${SCRIPT_PATH}/login_information.txt)
NextcloudDBName=$(grep -Pom 1 "(?<=^NextcloudDBName = ).*$" ${SCRIPT_PATH}/nextcloud_login_data.txt)
NextcloudDBUser=$(grep -Pom 1 "(?<=^NextcloudDBUser = ).*$" ${SCRIPT_PATH}/nextcloud_login_data.txt)

mysql -u root -p${MYSQL_ROOT_PASS} -e "DROP DATABASE IF EXISTS ${NextcloudDBName};"
mysql -u root -p${MYSQL_ROOT_PASS} -e "DROP USER ${NextcloudDBUser}@localhost;"

rm -rf /var/www/${MYDOMAIN}/public/${NEXTCLOUD_PATH_NAME}
rm ${SCRIPT_PATH}/nextcloud_login_data.txt
rm /etc/nginx/_nextcloud.conf
sed -i "s/include _nextcloud.conf;/#include _nextcloud.conf;/g" /etc/nginx/sites-available/${MYDOMAIN}.conf

systemctl -q restart php$PHPVERSION7-fpm.service
service nginx restart

sed -i 's/NEXTCLOUD_PATH_NAME=".*"/NEXTCLOUD_PATH_NAME="0"/' ${SCRIPT_PATH}/configs/userconfig.cfg
sed -i 's/NEXTCLOUD_IS_INSTALLED="1"/NEXTCLOUD_IS_INSTALLED="0"/' ${SCRIPT_PATH}/configs/userconfig.cfg
}
