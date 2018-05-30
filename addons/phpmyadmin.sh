#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_phpmyadmin() {

mkdir -p /usr/local/phpmyadmin/

install_packages "apache2-utils"

MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" /root/NeXt-Server/login_information.txt)

PMA_HTTPAUTH_USER=$(username)
MYSQL_PMADB_USER=$(username)
MYSQL_PMADB_NAME=$(username)

PMA_HTTPAUTH_PASS=$(password)
PMADB_PASS=$(password)
PMA_BFSECURE_PASS=$(password)

htpasswd -b /etc/nginx/htpasswd/.htpasswd ${PMA_HTTPAUTH_USER} ${PMA_HTTPAUTH_PASS} >>"${main_log}" 2>>"${err_log}"

cd /usr/local
wget_tar "https://codeload.github.com/phpmyadmin/phpmyadmin/tar.gz/RELEASE_${PMA_VERSION}"
tar_file "RELEASE_${PMA_VERSION}"
cp -R /usr/local/phpmyadmin-RELEASE_${PMA_VERSION}/* /usr/local/phpmyadmin/

cd /usr/local/phpmyadmin/
composer update >>"${main_log}" 2>>"${err_log}"

mkdir -p /usr/local/phpmyadmin/save
mkdir -p /usr/local/phpmyadmin/upload
chmod 0700 /usr/local/phpmyadmin/save
chmod g-s /usr/local/phpmyadmin/save
chmod 0700 /usr/local/phpmyadmin/upload
chmod g-s /usr/local/phpmyadmin/upload
mysql -u root -p${MYSQL_ROOT_PASS} mysql < phpmyadmin/sql/create_tables.sql >>"${main_log}" 2>>"${err_log}"

cp ${SCRIPT_PATH}/configs/pma/config.inc.php /usr/local/phpmyadmin/config.inc.php
sed -i "s/PMA_BFSECURE_PASS/${PMA_BFSECURE_PASS}/g" /usr/local/phpmyadmin/config.inc.php

cp ${SCRIPT_PATH}/addons/vhosts/phpmyadmin.conf /etc/nginx/sites-custom/phpmyadmin.conf

if [[ ${USE_PHP7_2} == '1' ]]; then
	sed -i 's/fastcgi_pass unix:\/var\/run\/php\/php7.1-fpm.sock\;/fastcgi_pass unix:\/var\/run\/php\/php7.2-fpm.sock\;/g' /etc/nginx/sites-custom/phpmyadmin.conf
fi

chown -R www-data:www-data /usr/local/phpmyadmin/
systemctl -q reload nginx.service

echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information.txt
echo "phpmyadmin" >> ${SCRIPT_PATH}/login_information.txt
echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt
echo "PMA_HTTPAUTH_USER = ${PMA_HTTPAUTH_USER}" >> ${SCRIPT_PATH}/login_information.txt
echo "PMA_HTTPAUTH_PASS = ${PMA_HTTPAUTH_PASS}" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt
echo "MYSQL_USERNAME: root" >> ${SCRIPT_PATH}/login_information.txt
echo "MYSQL_ROOT_PASS: $MYSQL_ROOT_PASS" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt
echo "MYSQL_PMADB_USER = ${MYSQL_PMADB_USER}" >> ${SCRIPT_PATH}/login_information.txt
echo "MYSQL_PMADB_NAME = ${MYSQL_PMADB_NAME}" >> ${SCRIPT_PATH}/login_information.txt
echo "PMADB_PASS = ${PMADB_PASS}" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt
echo "blowfish_secret = ${PMA_BFSECURE_PASS}" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt
}
