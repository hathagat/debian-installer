#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_phpmyadmin() {

mkdir -p /usr/local/phpmyadmin/

install_packages "apache2-utils"

MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" ${SCRIPT_PATH}/login_information.txt)

PMA_HTTPAUTH_USER=$(username)
MYSQL_PMADB_USER=$(username)
MYSQL_PMADB_NAME=$(username)
PMA_HTTPAUTH_PASS=$(password)
PMADB_PASS=$(password)
PMA_BFSECURE_PASS=$(password)

htpasswd -b /etc/nginx/htpasswd/.htpasswd ${PMA_HTTPAUTH_USER} ${PMA_HTTPAUTH_PASS} >>"${main_log}" 2>>"${err_log}"

cd /usr/local
git clone -b STABLE --depth=1 https://github.com/phpmyadmin/phpmyadmin.git phpmyadmin

cd /usr/local/phpmyadmin/
composer update --no-dev >>"${main_log}" 2>>"${err_log}"

mkdir -p /usr/local/phpmyadmin/{save,upload}
chmod 0700 /usr/local/phpmyadmin/save
chmod g-s /usr/local/phpmyadmin/save
chmod 0700 /usr/local/phpmyadmin/upload
chmod g-s /usr/local/phpmyadmin/upload
mysql -u root -p${MYSQL_ROOT_PASS} mysql < /usr/local/phpmyadmin/sql/create_tables.sql >>"${main_log}" 2>>"${err_log}"

cp ${SCRIPT_PATH}/configs/pma/config.inc.php /usr/local/phpmyadmin/config.inc.php
sed -i "s/PMA_BFSECURE_PASS/${PMA_BFSECURE_PASS}/g" /usr/local/phpmyadmin/config.inc.php

cp ${SCRIPT_PATH}/addons/vhosts/_phpmyadmin.conf /etc/nginx/_phpmyadmin.conf
sed -i "s/#include _phpmyadmin.conf;/include _phpmyadmin.conf;/g" /etc/nginx/sites-available/${MYDOMAIN}.conf

if [[ ${USE_PHP7_2} == '1' ]]; then
	sed -i "s/php7.1/php7.2/g" /etc/nginx/_phpmyadmin.conf
fi

chown -R www-data:www-data /usr/local/phpmyadmin/

systemctl -q restart php$PHPVERSION7-fpm.service
systemctl -q reload nginx.service

touch ${SCRIPT_PATH}/phpmyadmin_login_data.txt
echo "--------------------------------------------" >> ${SCRIPT_PATH}/phpmyadmin_login_data.txt
echo "phpmyadmin" >> ${SCRIPT_PATH}/phpmyadmin_login_data.txt
echo "--------------------------------------------" >> ${SCRIPT_PATH}/phpmyadmin_login_data.txt
echo "" >> ${SCRIPT_PATH}/phpmyadmin_login_data.txt
echo "PMA_HTTPAUTH_USER = ${PMA_HTTPAUTH_USER}" >> ${SCRIPT_PATH}/phpmyadmin_login_data.txt
echo "PMA_HTTPAUTH_PASS = ${PMA_HTTPAUTH_PASS}" >> ${SCRIPT_PATH}/phpmyadmin_login_data.txt
echo "" >> ${SCRIPT_PATH}/phpmyadmin_login_data.txt
echo "MYSQL_USERNAME: root" >> ${SCRIPT_PATH}/phpmyadmin_login_data.txt
echo "MYSQL_ROOT_PASS: $MYSQL_ROOT_PASS" >> ${SCRIPT_PATH}/phpmyadmin_login_data.txt
echo "" >> ${SCRIPT_PATH}/phpmyadmin_login_data.txt
echo "" >> ${SCRIPT_PATH}/phpmyadmin_login_data.txt
echo "MYSQL_PMADB_USER = ${MYSQL_PMADB_USER}" >> ${SCRIPT_PATH}/phpmyadmin_login_data.txt
echo "MYSQL_PMADB_NAME = ${MYSQL_PMADB_NAME}" >> ${SCRIPT_PATH}/phpmyadmin_login_data.txt
echo "PMADB_PASS = ${PMADB_PASS}" >> ${SCRIPT_PATH}/phpmyadmin_login_data.txt
echo "" >> ${SCRIPT_PATH}/phpmyadmin_login_data.txt
echo "blowfish_secret = ${PMA_BFSECURE_PASS}" >> ${SCRIPT_PATH}/phpmyadmin_login_data.txt

sed -i 's/PMA_IS_INSTALLED="0"/PMA_IS_INSTALLED="1"/' ${SCRIPT_PATH}/configs/userconfig.cfg

dialog_msg "Please save the shown login information on next page"
cat ${SCRIPT_PATH}/phpmyadmin_login_data.txt
source ${SCRIPT_PATH}/script/functions.sh; continue_or_exit
}
