#!/bin/bash
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_wordpress() {

trap error_exit ERR

source ${SCRIPT_PATH}/script/functions.sh; get_domain

WORDPRESS_USER=$(username)
WORDPRESS_DB_NAME=$(username)
WORDPRESS_DB_PASS=$(password)
WORDPRESS_DB_PREFIX=$(username)
MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" ${SCRIPT_PATH}/login_information.txt)

mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE DATABASE ${WORDPRESS_DB_NAME};"
mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE USER ${WORDPRESS_USER}@localhost IDENTIFIED BY '${WORDPRESS_DB_PASS}';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "GRANT ALL PRIVILEGES ON ${WORDPRESS_DB_NAME}.* TO '${WORDPRESS_USER}'@'localhost';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "FLUSH PRIVILEGES;"

cd /var/www/${MYDOMAIN}/public/
wget_tar "https://wordpress.org/latest.tar.gz"
tar -zxvf latest.tar.gz
rm latest.tar.gz

if [ "$WORDPRESS_PATH_NAME" == "wordpress" ]; then
  cd wordpress
else
  mv wordpress ${WORDPRESS_PATH_NAME}
  cd ${WORDPRESS_PATH_NAME}
fi

cp wp-config-sample.php wp-config.php

sed -i "s/wp_/${WORDPRESS_DB_PREFIX}_/g" wp-config.php
sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/g" wp-config.php
sed -i "s/username_here/${WORDPRESS_USER}/g" wp-config.php
sed -i "s/password_here/${WORDPRESS_DB_PASS}/g" wp-config.php

salts=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
while read -r salt; do
  search="define('$(echo "$salt" | cut -d "'" -f 2)"
  replace=$(echo "$salt" | cut -d "'" -f 4)
    sed -i "/^$search/s/put your unique phrase here/$(echo $replace | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')/" wp-config.php
done <<< "$salts"

mkdir -p /var/www/${MYDOMAIN}/public/${WORDPRESS_PATH_NAME}/wp-content/uploads

chown www-data:www-data -R *
find . -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;

cp ${SCRIPT_PATH}/addons/vhosts/_wordpress.conf /etc/nginx/_wordpress.conf
sed -i "s/#include _wordpress.conf;/include _wordpress.conf;/g" /etc/nginx/sites-available/${MYDOMAIN}.conf

systemctl -q restart php$PHPVERSION7-fpm.service
systemctl restart nginx

touch ${SCRIPT_PATH}/wordpress_login_data.txt
echo "--------------------------------------------" >> ${SCRIPT_PATH}/wordpress_login_data.txt
echo "Wordpress" >> ${SCRIPT_PATH}/wordpress_login_data.txt
echo "--------------------------------------------" >> ${SCRIPT_PATH}/wordpress_login_data.txt
echo "https://${MYDOMAIN}/${WORDPRESS_PATH_NAME}" >> ${SCRIPT_PATH}/wordpress_login_data.txt
echo "WordpressDBUser = ${WORDPRESS_USER}" >> ${SCRIPT_PATH}/wordpress_login_data.txt
echo "WordpressDBName = ${WORDPRESS_DB_NAME}" >> ${SCRIPT_PATH}/wordpress_login_data.txt
echo "WordpressDBPassword = ${WORDPRESS_DB_PASS}" >> ${SCRIPT_PATH}/wordpress_login_data.txt
echo "WordpressScriptPath = ${WORDPRESS_PATH_NAME}" >> ${SCRIPT_PATH}/wordpress_login_data.txt

sed -i 's/WORDPRESS_IS_INSTALLED="0"/WORDPRESS_IS_INSTALLED="1"/' ${SCRIPT_PATH}/configs/userconfig.cfg

dialog_msg "Please save the shown login information on next page"
cat ${SCRIPT_PATH}/wordpress_login_data.txt
source ${SCRIPT_PATH}/script/functions.sh; continue_or_exit
}
