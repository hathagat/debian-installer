#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#
	# This program is free software; you can redistribute it and/or modify
    # it under the terms of the GNU General Public License as published by
    # the Free Software Foundation; either version 2 of the License, or
    # (at your option) any later version.

    # This program is distributed in the hope that it will be useful,
    # but WITHOUT ANY WARRANTY; without even the implied warranty of
    # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    # GNU General Public License for more details.

    # You should have received a copy of the GNU General Public License along
    # with this program; if not, write to the Free Software Foundation, Inc.,
    # 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#-------------------------------------------------------------------------------------------------------------


install_phpmyadmin() {
  set -x

apt-get -y --assume-yes install apache2-utils >>"${main_log}" 2>>"${err_log}"

MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" /root/NeXt-Server/login_information)
PMA_HTTPAUTH_USER="httpauth"
MYSQL_PMADB_USER="phpmyadmin"
MYSQL_PMADB_NAME="phpmyadmin"
PMA_HTTPAUTH_PASS=$(password)
PMADB_PASS=$(password)
PMA_USER_PASS=$(password)

htpasswd -b /etc/nginx/htpasswd/.htpasswd ${PMA_HTTPAUTH_USER} ${PMA_HTTPAUTH_PASS} >>"${main_log}" 2>>"${err_log}"

cd /usr/local
git clone -b STABLE https://github.com/phpmyadmin/phpmyadmin.git -q >>"${main_log}" 2>>"${err_log}"
cd /usr/local/phpmyadmin
composer update --no-dev >>"${main_log}" 2>>"${err_log}"
cd /usr/local
mkdir -p phpmyadmin/save
mkdir -p phpmyadmin/upload
chmod 0700 phpmyadmin/save
chmod g-s phpmyadmin/save
chmod 0700 phpmyadmin/upload
chmod g-s phpmyadmin/upload
mysql -u root -p${MYSQL_ROOT_PASS} mysql < phpmyadmin/sql/create_tables.sql >>"${main_log}" 2>>"${err_log}"
mysql -u root -p${MYSQL_ROOT_PASS} -e "GRANT USAGE ON mysql.* TO '${MYSQL_PMADB_USER}'@'${MYSQL_HOSTNAME}' IDENTIFIED BY '${PMADB_PASS}'; GRANT SELECT ( Host, User, Select_priv, Insert_priv, Update_priv, Delete_priv, Create_priv, Drop_priv, Reload_priv, Shutdown_priv, Process_priv, File_priv, Grant_priv, References_priv, Index_priv, Alter_priv, Show_db_priv, Super_priv, Create_tmp_table_priv, Lock_tables_priv, Execute_priv, Repl_slave_priv, Repl_client_priv ) ON mysql.user TO '${MYSQL_PMADB_USER}'@'${MYSQL_HOSTNAME}'; GRANT SELECT ON mysql.db TO '${MYSQL_PMADB_USER}'@'${MYSQL_HOSTNAME}'; GRANT SELECT (Host, Db, User, Table_name, Table_priv, Column_priv) ON mysql.tables_priv TO '${MYSQL_PMADB_USER}'@'${MYSQL_HOSTNAME}'; GRANT SELECT, INSERT, DELETE, UPDATE, ALTER ON ${MYSQL_PMADB_NAME}.* TO '${MYSQL_PMADB_USER}'@'${MYSQL_HOSTNAME}'; FLUSH PRIVILEGES;" >>"${main_log}" 2>>"${err_log}"

# Add a new User to login into phpmyadmin
mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE USER 'prsphpmyadmin'@'localhost' IDENTIFIED BY '${PMA_USER_PASS}';GRANT ALL PRIVILEGES ON *.* TO 'prsphpmyadmin'@'localhost' WITH GRANT OPTION;FLUSH PRIVILEGES;" >>"${main_log}" 2>>"${err_log}"

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
\$cfg['Servers'][\$i]['auth_http_realm'] = 'phpMyAdmin Login';
\$cfg['Servers'][\$i]['host'] = '${MYSQL_HOSTNAME}';
\$cfg['Servers'][\$i]['connect_type'] = 'tcp';
\$cfg['Servers'][\$i]['compress'] = false;
\$cfg['Servers'][\$i]['extension'] = 'mysqli';
\$cfg['Servers'][\$i]['AllowNoPassword'] = false;
\$cfg['Servers'][\$i]['controluser'] = '$MYSQL_PMADB_USER';
\$cfg['Servers'][\$i]['controlpass'] = '$PMADB_PASS';
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

sed -i "64s/.*/\$cfg['Servers'][\$i]['AllowDeny']['order'] = 'deny,allow';\n&/" /usr/local/phpmyadmin/config.inc.php
sed -i "65s/.*/\$cfg['Servers'][\$i]['AllowDeny']['rules'] = array(\n&/" /usr/local/phpmyadmin/config.inc.php
sed -i "66s/.*/		'deny % from all',\n&/" /usr/local/phpmyadmin/config.inc.php
sed -i "67s/.*/		'allow % from localhost',\n&/" /usr/local/phpmyadmin/config.inc.php
sed -i "68s/.*/		'allow % from 127.0.0.1',\n&/" /usr/local/phpmyadmin/config.inc.php
sed -i "69s/.*/		'allow % from ::1',\n&/" /usr/local/phpmyadmin/config.inc.php
sed -i "70s/.*/		'allow root from localhost',\n&/" /usr/local/phpmyadmin/config.inc.php
sed -i "71s/.*/		'allow root from 127.0.0.1',\n&/" /usr/local/phpmyadmin/config.inc.php
sed -i "72s/.*/		'allow root from ::1',\n&/" /usr/local/phpmyadmin/config.inc.php
sed -i "73s/.*/);\n&/" /usr/local/phpmyadmin/config.inc.php
sed -i "74s/.*/?>/" /usr/local/phpmyadmin/config.inc.php

cat > /etc/nginx/sites-custom/phpmyadmin.conf <<END
location /pma {
    auth_basic "Restricted";
    alias /usr/local/phpmyadmin;
    index index.php;
    location ~ ^/pma/(.+\.php)$ {
        alias /usr/local/phpmyadmin/\$1;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        include fastcgi_params;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME /usr/local/phpmyadmin/\$1;
        fastcgi_pass unix:/var/run/php/php7.1-fpm.sock;
    }
    location ~* ^/pma/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
        alias /usr/local/phpmyadmin/\$1;
    }
    location ~ ^/pma/save/ {
        deny all;
    }
    location ~ ^/pma/upload/ {
        deny all;
    }
}
END

if [[ ${USE_PHP7_2} == '1' ]]; then
	sed -i 's/fastcgi_pass unix:\/var\/run\/php\/php7.1-fpm.sock\;/fastcgi_pass unix:\/var\/run\/php\/php7.2-fpm.sock\;/g' /etc/nginx/sites-custom/phpmyadmin.conf
fi

chown -R www-data:www-data phpmyadmin/
systemctl -q reload nginx.service

echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information
echo "phpmyadmin" >> ${SCRIPT_PATH}/login_information
echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information
echo "PMA_HTTPAUTH_USER = ${PMA_HTTPAUTH_USER}" >> ${SCRIPT_PATH}/login_information
echo "MYSQL_PMADB_USER = phpmyadmin" >> ${SCRIPT_PATH}/login_information
echo "MYSQL_PMADB_NAME = phpmyadmin" >> ${SCRIPT_PATH}/login_information
echo "PMA_HTTPAUTH_PASS = ${PMA_HTTPAUTH_PASS}" >> ${SCRIPT_PATH}/login_information
echo "PMADB_PASS = ${PMADB_PASS}" >> ${SCRIPT_PATH}/login_information
echo "PMA_USER_PASS = ${PMA_USER_PASS}" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information
}
