#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_nextcloud() {

install_packages "unzip"

MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" ${SCRIPT_PATH}/login_information.txt)
NEXTCLOUD_USER=$(username)
NEXTCLOUD_DB_PASS=$(password)
NEXTCLOUD_DB_NAME=$(username)

mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE DATABASE ${NEXTCLOUD_DB_NAME};"
mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE USER '${NEXTCLOUD_USER}'@'localhost' IDENTIFIED BY '${NEXTCLOUD_DB_PASS}';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "GRANT ALL PRIVILEGES ON ${NEXTCLOUD_DB_NAME}.* TO '${NEXTCLOUD_USER}'@'localhost';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "FLUSH PRIVILEGES;"

cd /var/www/${MYDOMAIN}/public/
wget_tar "https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.zip"
unzip_file "nextcloud-${NEXTCLOUD_VERSION}.zip"
rm nextcloud-${NEXTCLOUD_VERSION}.zip

if [ "$NEXTCLOUD_PATH_NAME" == "nextcloud" ]; then
  cd nextcloud
else
  mv nextcloud ${NEXTCLOUD_PATH_NAME}
  cd ${NEXTCLOUD_PATH_NAME}
fi

chown -R www-data: /var/www/${MYDOMAIN}/public/${NEXTCLOUD_PATH_NAME}

cp ${SCRIPT_PATH}/addons/vhosts/_nextcloud.conf /etc/nginx/_nextcloud.conf
sed -i "s/#include _nextcloud.conf;/include _nextcloud.conf;/g" /etc/nginx/sites-available/${MYDOMAIN}.conf

if [[ ${USE_PHP7_2} == '1' ]]; then
	sed -i "s/php7.1/php7.2/g" /etc/nginx/_nextcloud.conf >>"${main_log}" 2>>"${err_log}"
fi
sed -i "s/change_path/${NEXTCLOUD_PATH_NAME}/g" /etc/nginx/_nextcloud.conf

systemctl -q restart php$PHPVERSION7-fpm.service
systemctl -q reload nginx.service

touch ${SCRIPT_PATH}/nextcloud_login_data.txt
echo "--------------------------------------------" >> ${SCRIPT_PATH}/nextcloud_login_data.txt
echo "Nextcloud" >> ${SCRIPT_PATH}/nextcloud_login_data.txt
echo "--------------------------------------------" >> ${SCRIPT_PATH}/nextcloud_login_data.txt
echo "https://${MYDOMAIN}/${NEXTCLOUD_PATH_NAME}" >> ${SCRIPT_PATH}/nextcloud_login_data.txt
echo "NextcloudDBUser = ${NEXTCLOUD_USER}" >> ${SCRIPT_PATH}/nextcloud_login_data.txt
echo "Database password = ${NEXTCLOUD_DB_PASS}" >> ${SCRIPT_PATH}/nextcloud_login_data.txt
echo "NextcloudDBName = ${NEXTCLOUD_DB_NAME}" >> ${SCRIPT_PATH}/nextcloud_login_data.txt

sed -i 's/NEXTCLOUD_IS_INSTALLED="0"/NEXTCLOUD_IS_INSTALLED="1"/' ${SCRIPT_PATH}/configs/userconfig.cfg

dialog_msg "Please save the shown login information on next page"
cat ${SCRIPT_PATH}/nextcloud_login_data.txt
source ${SCRIPT_PATH}/script/functions.sh; continue_or_exit
}
