#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_phpmyadmin() {

set -x

mkdir -p phpmyadmin/

install_packages "apache2-utils"

MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" /root/NeXt-Server/login_information.txt)

PMA_HTTPAUTH_USER=$(username)
MYSQL_PMADB_USER=$(username)
MYSQL_PMADB_NAME=$(username)
NXTPMAROOTUSER=$(username)

PMA_HTTPAUTH_PASS=$(password)
PMADB_PASS=$(password)
PMA_USER_PASS=$(password)
PMA_BFSECURE_PASS=$(password)

htpasswd -b /etc/nginx/htpasswd/.htpasswd ${PMA_HTTPAUTH_USER} ${PMA_HTTPAUTH_PASS} >>"${main_log}" 2>>"${err_log}"

cd /usr/local
wget_tar "https://codeload.github.com/phpmyadmin/phpmyadmin/tar.gz/RELEASE_${PMA_VERSION}"
tar_file "RELEASE_${PMA_VERSION}"
cp -R /usr/local/phpmyadmin-RELEASE_${PMA_VERSION}/* /usr/local/phpmyadmin/

cd /usr/local/phpmyadmin/
composer update >>"${main_log}" 2>>"${err_log}"

cd /usr/local
mkdir -p phpmyadmin/save
mkdir -p phpmyadmin/upload
chmod 0700 phpmyadmin/save
chmod g-s phpmyadmin/save
chmod 0700 phpmyadmin/upload
chmod g-s phpmyadmin/upload
mysql -u root -p${MYSQL_ROOT_PASS} mysql < phpmyadmin/sql/create_tables.sql >>"${main_log}" 2>>"${err_log}"

# Generate PMA USER
mysql -u root -p${MYSQL_ROOT_PASS} -e "GRANT USAGE ON mysql.* TO '${MYSQL_PMADB_USER}'@'${MYSQL_HOSTNAME}' IDENTIFIED BY '${PMADB_PASS}'; GRANT SELECT ( Host, User, Select_priv, Insert_priv, Update_priv, Delete_priv, Create_priv, Drop_priv, Reload_priv, Shutdown_priv, Process_priv, File_priv, Grant_priv, References_priv, Index_priv, Alter_priv, Show_db_priv, Super_priv, Create_tmp_table_priv, Lock_tables_priv, Execute_priv, Repl_slave_priv, Repl_client_priv ) ON mysql.user TO '${MYSQL_PMADB_USER}'@'${MYSQL_HOSTNAME}'; GRANT SELECT ON mysql.db TO '${MYSQL_PMADB_USER}'@'${MYSQL_HOSTNAME}'; GRANT SELECT (Host, Db, User, Table_name, Table_priv, Column_priv) ON mysql.tables_priv TO '${MYSQL_PMADB_USER}'@'${MYSQL_HOSTNAME}'; GRANT SELECT, INSERT, DELETE, UPDATE, ALTER ON ${MYSQL_PMADB_NAME}.* TO '${MYSQL_PMADB_USER}'@'${MYSQL_HOSTNAME}'; FLUSH PRIVILEGES;" >>"${main_log}" 2>>"${err_log}"

cp ${SCRIPT_PATH}/configs/pma/config.inc.php /usr/local/phpmyadmin/config.inc.php
sed -i "s/^MYSQL_HOSTNAME/${MYSQL_HOSTNAME}/g" /usr/local/phpmyadmin/config.inc.php
sed -i "s/^PMA_BFSECURE_PASSE/${PMA_BFSECURE_PASS}/g" /usr/local/phpmyadmin/config.inc.php
sed -i "s/^MYSQL_PMADB_USER/${MYSQL_PMADB_USER}/g" /usr/local/phpmyadmin/config.inc.php
sed -i "s/^PMADB_PASS/${PMADB_PASS}/g" /usr/local/phpmyadmin/config.inc.php
sed -i "s/^MYSQL_PMADB_NAME/${MYSQL_PMADB_NAME}/g" /usr/local/phpmyadmin/config.inc.php

cp ${SCRIPT_PATH}/addons/vhosts/phpmyadmin.conf /etc/nginx/sites-custom/phpmyadmin.conf

if [[ ${USE_PHP7_2} == '1' ]]; then
	sed -i 's/fastcgi_pass unix:\/var\/run\/php\/php7.1-fpm.sock\;/fastcgi_pass unix:\/var\/run\/php\/php7.2-fpm.sock\;/g' /etc/nginx/sites-custom/phpmyadmin.conf
fi

chown -R www-data:www-data phpmyadmin/
systemctl -q reload nginx.service

echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information.txt
echo "phpmyadmin" >> ${SCRIPT_PATH}/login_information.txt
echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information.txt
echo "MYSQL_PMADB_USER = ${MYSQL_PMADB_USER}" >> ${SCRIPT_PATH}/login_information.txt
echo "MYSQL_PMADB_NAME = ${MYSQL_PMADB_NAME}" >> ${SCRIPT_PATH}/login_information.txt
echo "PMADB_PASS = ${PMADB_PASS}" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt
echo "PMA_HTTPAUTH_USER = ${PMA_HTTPAUTH_USER}" >> ${SCRIPT_PATH}/login_information.txt
echo "PMA_HTTPAUTH_PASS = ${PMA_HTTPAUTH_PASS}" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt
echo "Your Root User" >> ${SCRIPT_PATH}/login_information.txt
echo "PMA_USER = ${NXTPMAROOTUSER}" >> ${SCRIPT_PATH}/login_information.txt
echo "PMA_USER_PASS = ${PMA_USER_PASS}" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt
echo "blowfish_secret = ${PMA_BFSECURE_PASS}" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt
}
