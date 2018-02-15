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

install_nextcloud() {

set -x

DEBIAN_FRONTEND=noninteractive apt-get -y install unzip >>"${main_log}" 2>>"${err_log}"

MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" /root/NeXt-Server/login_information)
echo "${MYSQL_ROOT_PASS}"
NEXTCLOUD_DB_PASS=$(password)

mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE DATABASE nextclouddb;"
mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY '${NEXTCLOUD_DB_PASS}';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "GRANT ALL PRIVILEGES ON nextclouddb.* TO 'nextcloud'@'localhost';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "FLUSH PRIVILEGES;"

cd /srv/
wget https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.zip >>"${main_log}" 2>>"${err_log}"
unzip nextcloud-${NEXTCLOUD_VERSION}.zip
rm nextcloud-${NEXTCLOUD_VERSION}.zip

chown -R www-data: /srv/nextcloud
ln -s /srv/nextcloud/ /etc/nginx/html/${MYDOMAIN}/nextcloud >>"${main_log}" 2>>"${err_log}"

mysql --defaults-file=/etc/mysql/debian.cnf -e "CREATE DATABASE nextcloud; GRANT ALL ON nextcloud.* TO 'nextcloud'@'localhost' IDENTIFIED BY '${NEXTCLOUD_DB_PASS}'; FLUSH PRIVILEGES;" >>"${main_log}" 2>>"${err_log}"

#Nginx custom site config
cat >> /etc/nginx/sites-custom/nextcloud.conf << 'EOF1'
pagespeed off;

location /nextcloud {
    rewrite ^ /nextcloud/index.php$uri;
}

location ~ ^/nextcloud/(?:build|tests|config|lib|3rdparty|templates|data)/ {
    deny all;
}
location ~ ^/nextcloud/(?:\.|autotest|occ|issue|indie|db_|console) {
    deny all;
}

location ~ ^/nextcloud/(?:index|remote|public|cron|core/ajax/update|status|ocs/v[12]|updater/.+|ocs-provider/.+)\.php(?:$|/) {
    fastcgi_split_path_info ^(.+\.php)(/.*)$;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_param PATH_INFO $fastcgi_path_info;
    fastcgi_param HTTPS on;
    #Avoid sending the security headers twice
    fastcgi_param modHeadersAvailable true;
    fastcgi_param front_controller_active true;
    fastcgi_pass unix:/var/run/php/php7.1-fpm.sock;
    fastcgi_intercept_errors on;
    fastcgi_request_buffering off;
}

location ~ ^/nextcloud/(?:updater|ocs-provider)(?:$|/) {
    try_files $uri/ =404;
    index index.php;
}

location ~ \.(?:css|js|woff|svg|gif)$ {
    try_files $uri /nextcloud/index.php$uri$is_args$args;
    add_header Cache-Control "public, max-age=15778463";
    # Add headers to serve security related headers  (It is intended
    # to have those duplicated to the ones above)
    # Before enabling Strict-Transport-Security headers please read
    # into this topic first.
    # add_header Strict-Transport-Security "max-age=15768000;
    # includeSubDomains; preload;";
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Robots-Tag none;
    add_header X-Download-Options noopen;
    add_header X-Permitted-Cross-Domain-Policies none;
    # Optional: Don't log access to assets
    access_log off;
}
EOF1

if [[ ${USE_PHP7_2} == '1' ]]; then
	sed -i 's/fastcgi_pass unix:\/var\/run\/php\/php7.1-fpm.sock\;/fastcgi_pass unix:\/var\/run\/php\/php7.2-fpm.sock\;/g' /etc/nginx/sites-custom/nextcloud.conf >>"${main_log}" 2>>"${err_log}"
fi

ln -s /etc/nginx/sites-available/cloud.${MYDOMAIN}.conf /etc/nginx/sites-enabled/cloud.${MYDOMAIN}.conf

echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information
echo "Nextcloud" >> ${SCRIPT_PATH}/login_information
echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information
echo "https://${MYDOMAIN}/nextcloud" >> ${SCRIPT_PATH}/login_information
echo "Database User: nextcloud" >> ${SCRIPT_PATH}/login_information
echo "Database password = ${NEXTCLOUD_DB_PASS}" >> ${SCRIPT_PATH}/login_information
echo "Database name = nextcloud" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information

}
