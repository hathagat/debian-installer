#!/bin/bash

install_phpmyadmin() {

set -x

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
git clone -b STABLE https://github.com/phpmyadmin/phpmyadmin.git -q >>"${main_log}" 2>>"${err_log}"
cd /usr/local/phpmyadmin
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

# Add a new User to login into phpmyadmin
mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE USER ${NXTPMAROOTUSER}@localhost IDENTIFIED BY '${PMA_USER_PASS}';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "GRANT ALL PRIVILEGES ON *.* TO '${NXTPMAROOTUSER}'@'localhost';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "FLUSH PRIVILEGES;"

cat > phpmyadmin/config.inc.php <<END
<?php
\$cfg['blowfish_secret'] = '$PMA_BFSECURE_PASS';
\$i = 0;
\$i++;
\$cfg['UploadDir'] = 'upload';
\$cfg['SaveDir'] = 'save';
\$cfg['ForceSSL'] = true;
\$cfg['ExecTimeLimit'] = 300;
\$cfg['VersionCheck'] = false;
\$cfg['NavigationTreeEnableGrouping'] = false;
\$cfg['AllowArbitraryServer'] = true;
\$cfg['AllowThirdPartyFraming'] = true;
\$cfg['ShowServerInfo'] = false;
\$cfg['ShowDbStructureCreation'] = true;
\$cfg['ShowDbStructureLastUpdate'] = true;
\$cfg['ShowDbStructureLastCheck'] = true;
\$cfg['UserprefsDisallow'] = array(
    'ShowServerInfo',
    'ShowDbStructureCreation',
    'ShowDbStructureLastUpdate',
    'ShowDbStructureLastCheck',
    'Export/quick_export_onserver',
    'Export/quick_export_onserver_overwrite',
    'Export/onserver');
\$cfg['Import']['charset'] = 'utf-8';
\$cfg['Export']['quick_export_onserver'] = true;
\$cfg['Export']['quick_export_onserver_overwrite'] = true;
\$cfg['Export']['compression'] = 'gzip';
\$cfg['Export']['charset'] = 'utf-8';
\$cfg['Export']['onserver'] = true;
\$cfg['Export']['sql_drop_database'] = true;
\$cfg['DefaultLang'] = 'en';
\$cfg['ServerDefault'] = 1;
\$cfg['Servers'][\$i]['auth_type'] = 'cookie';
\$cfg['Servers'][$i]['AllowRoot'] = false;
\$cfg['Servers'][\$i]['auth_http_realm'] = 'phpMyAdmin Login';
\$cfg['Servers'][\$i]['host'] = '${MYSQL_HOSTNAME}';
\$cfg['Servers'][\$i]['connect_type'] = 'tcp';
\$cfg['Servers'][\$i]['compress'] = false;
\$cfg['Servers'][\$i]['extension'] = 'mysqli';
\$cfg['Servers'][\$i]['AllowNoPassword'] = false;
\$cfg['Servers'][\$i]['controluser'] = '$NXTPMAROOTUSER';
\$cfg['Servers'][\$i]['controlpass'] = '$PMA_USER_PASS';
\$cfg['Servers'][\$i]['pmadb'] = '$MYSQL_PMADB_NAME';
\$cfg['Servers'][\$i]['bookmarktable'] = 'pma__bookmark';
\$cfg['Servers'][\$i]['relation'] = 'pma__relation';
\$cfg['Servers'][\$i]['table_info'] = 'pma__table_info';
\$cfg['Servers'][\$i]['table_coords'] = 'pma__table_coords';
\$cfg['Servers'][\$i]['pdf_pages'] = 'pma__pdf_pages';
\$cfg['Servers'][\$i]['column_info'] = 'pma__column_info';
\$cfg['Servers'][\$i]['history'] = 'pma__history';
\$cfg['Servers'][\$i]['table_uiprefs'] = 'pma__table_uiprefs';
\$cfg['Servers'][\$i]['tracking'] = 'pma__tracking';
\$cfg['Servers'][\$i]['userconfig'] = 'pma__userconfig';
\$cfg['Servers'][\$i]['recent'] = 'pma__recent';
\$cfg['Servers'][\$i]['favorite'] = 'pma__favorite';
\$cfg['Servers'][\$i]['users'] = 'pma__users';
\$cfg['Servers'][\$i]['usergroups'] = 'pma__usergroups';
\$cfg['Servers'][\$i]['navigationhiding'] = 'pma__navigationhiding';
\$cfg['Servers'][\$i]['savedsearches'] = 'pma__savedsearches';
\$cfg['Servers'][\$i]['central_columns'] = 'pma__central_columns';
\$cfg['Servers'][\$i]['designer_settings'] = 'pma__designer_settings';
\$cfg['Servers'][\$i]['export_templates'] = 'pma__export_templates';
\$cfg['Servers'][\$i]['hide_db'] = 'information_schema';
?>
END

cp ${SCRIPT_PATH}/addons/vhosts/phpmyadmin.conf /etc/nginx/sites-custom/phpmyadmin.conf

if [[ ${USE_PHP5} == '1' ]]; then
	sed -i 's/fastcgi_pass unix:\/var\/run\/php\/php7.1-fpm.sock\;/fastcgi_pass unix:\/var\/run\/php5-fpm.sock\;/g' /etc/nginx/sites-custom/phpmyadmin.conf
fi

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
