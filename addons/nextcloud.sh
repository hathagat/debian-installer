#!/bin/bash

install_nextcloud() {

install_packages "unzip"

MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" /root/NeXt-Server/login_information.txt)
NEXTCLOUD_DB_PASS=$(password)

mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE DATABASE nextclouddb;"
mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY '${NEXTCLOUD_DB_PASS}';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "GRANT ALL PRIVILEGES ON nextclouddb.* TO 'nextcloud'@'localhost';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "FLUSH PRIVILEGES;"

cd /srv/
wget_tar "https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.zip"
unzip_file "nextcloud-${NEXTCLOUD_VERSION}.zip"
rm nextcloud-${NEXTCLOUD_VERSION}.zip

chown -R www-data: /srv/nextcloud
ln -s /srv/nextcloud/ /etc/nginx/html/${MYDOMAIN}/nextcloud >>"${main_log}" 2>>"${err_log}"

cp ${SCRIPT_PATH}/addons/vhosts/nextcloud.conf /etc/nginx/sites-custom/nextcloud.conf

if [[ ${USE_PHP5} == '1' ]]; then
	sed -i 's/fastcgi_pass unix:\/var\/run\/php\/php7.1-fpm.sock\;/fastcgi_pass unix:\/var\/run\/php5-fpm.sock\;/g' /etc/nginx/sites-custom/phpmyadmin.conf
fi

if [[ ${USE_PHP7_2} == '1' ]]; then
	sed -i 's/fastcgi_pass unix:\/var\/run\/php\/php7.1-fpm.sock\;/fastcgi_pass unix:\/var\/run\/php\/php7.2-fpm.sock\;/g' /etc/nginx/sites-custom/nextcloud.conf >>"${main_log}" 2>>"${err_log}"
fi

systemctl -q reload nginx.service

echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information.txt
echo "Nextcloud" >> ${SCRIPT_PATH}/login_information.txt
echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information.txt
echo "https://${MYDOMAIN}/nextcloud" >> ${SCRIPT_PATH}/login_information.txt
echo "Database name = nextclouddb" >> ${SCRIPT_PATH}/login_information.txt
echo "Database User: nextcloud" >> ${SCRIPT_PATH}/login_information.txt
echo "Database password = ${NEXTCLOUD_DB_PASS}" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt

echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information.txt_nextcloud
echo "Nextcloud" >> ${SCRIPT_PATH}/login_information.txt_nextcloud
echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information.txt_nextcloud
echo "https://${MYDOMAIN}/nextcloud" >> ${SCRIPT_PATH}/login_information.txt_nextcloud
echo "Database name = nextclouddb" >> ${SCRIPT_PATH}/login_information.txt_nextcloud
echo "Database User: nextcloud" >> ${SCRIPT_PATH}/login_information.txt_nextcloud
echo "Database password = ${NEXTCLOUD_DB_PASS}" >> ${SCRIPT_PATH}/login_information.txt_nextcloud
echo "" >> ${SCRIPT_PATH}/login_information.txt_nextcloud


dialog --title "Your Nextcloud logininformations" --tab-correct --exit-label "ok" --textbox ${SCRIPT_PATH}/login_information.txt_nextcloud 50 200
}
