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

cd /srv/
wget_tar "https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.zip"
unzip_file "nextcloud-${NEXTCLOUD_VERSION}.zip"
rm nextcloud-${NEXTCLOUD_VERSION}.zip

chown -R www-data: /srv/nextcloud
ln -s /srv/nextcloud/ /var/www/${MYDOMAIN}/public/nextcloud >>"${main_log}" 2>>"${err_log}"

cp ${SCRIPT_PATH}/addons/vhosts/_nextcloud.conf /etc/nginx/_nextcloud.conf
sed -i "s/#include _nextcloud.conf;/include _nextcloud.conf;/g" /etc/nginx/sites-available/${MYDOMAIN}.conf

if [[ ${USE_PHP7_2} == '1' ]]; then
	sed -i 's/fastcgi_pass unix:\/var\/run\/php\/php7.1-fpm.sock\;/fastcgi_pass unix:\/var\/run\/php\/php7.2-fpm.sock\;/g' /etc/nginx/sites-custom/nextcloud.conf >>"${main_log}" 2>>"${err_log}"
fi

systemctl -q restart php$PHPVERSION7-fpm.service
systemctl -q reload nginx.service

touch ${SCRIPT_PATH}/nextcloud_login_data.txt
echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information.txt_nextcloud
echo "Nextcloud" >> ${SCRIPT_PATH}/nextcloud_login_data.txt
echo "--------------------------------------------" >> ${SCRIPT_PATH}/nextcloud_login_data.txt
echo "https://${MYDOMAIN}/${NEXTCLOUD_PATH_NAME}" >> ${SCRIPT_PATH}/nextcloud_login_data.txt
echo "NextcloudDBName = ${NEXTCLOUD_DB_NAME}" >> ${SCRIPT_PATH}/nextcloud_login_data.txt
echo "NextcloudDBUser = ${NEXTCLOUD_USER}" >> ${SCRIPT_PATH}/nextcloud_login_data.txt
echo "Database password = ${NEXTCLOUD_DB_PASS}" >> ${SCRIPT_PATH}/nextcloud_login_data.txt
echo "" >> ${SCRIPT_PATH}/nextcloud_login_data.txt
}
