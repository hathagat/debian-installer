#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
# thx to https://gist.github.com/bgallagh3r
#-------------------------------------------------------------------------------------------------------------

install_wordpress() {

source ${SCRIPT_PATH}/script/functions.sh; get_domain

WORDPRESS_USER=$(username)
WORDPRESS_DB_NAME=$(username)
WORDPRESS_DB_PASS=$(password)
WORDPRESS_DB_PREFIX=$(username)
MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" /root/NeXt-Server/login_information.txt)

mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE DATABASE ${WORDPRESS_DB_NAME};"
mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE USER ${WORDPRESS_USER}@localhost IDENTIFIED BY '${WORDPRESS_DB_PASS}';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "GRANT ALL PRIVILEGES ON ${WORDPRESS_DB_NAME}.* TO '${WORDPRESS_USER}'@'localhost';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "FLUSH PRIVILEGES;"

cd /var/www/${MYDOMAIN}/public/

wget_tar "https://wordpress.org/latest.tar.gz"
tar -zxvf latest.tar.gz
rm latest.tar.gz

cd wordpress
cp wp-config-sample.php wp-config.php

# Change prefix random
sed -i "s/wp_/${WORDPRESS_DB_PREFIX}_/g" wp-config.php

#set database details - find and replace
sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/g" wp-config.php
sed -i "s/username_here/${WORDPRESS_USER}/g" wp-config.php
sed -i "s/password_here/${WORDPRESS_DB_PASS}/g" wp-config.php

# Get salts
salts=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
while read -r salt; do
  search="define('$(echo "$salt" | cut -d "'" -f 2)"
  replace=$(echo "$salt" | cut -d "'" -f 4)
    sed -i "/^$search/s/put your unique phrase here/$(echo $replace | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')/" wp-config.php
done <<< "$salts"

mkdir -p /wp-content/uploads

find . -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;

cp ${SCRIPT_PATH}/configs/nginx/_wordpress.conf /etc/nginx/_wordpress.conf

systemctl restart nginx

dialog_msg "Visit ${MYDOMAIN}/${WORDPRESSPATHNAME} to finish the installation"

echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information.txt
echo "Wordpress" >> ${SCRIPT_PATH}/login_information.txt
echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information.txt
echo "https://${MYDOMAIN}/${WORDPRESSPATHNAME}" >> ${SCRIPT_PATH}/login_information.txt
echo "WordpressDBUser = ${WORDPRESS_USER}" >> ${SCRIPT_PATH}/login_information.txt
echo "WordpressDBName = ${WORDPRESS_DB_NAME}" >> ${SCRIPT_PATH}/login_information.txt
echo "WordpressDBPassword = ${WORDPRESS_DB_PASS}" >> ${SCRIPT_PATH}/login_information.txt
if [ -z "${WORDPRESSPATHNAME}" ]; then
echo "WordpressScriptPath = ${MYDOMAIN}" >> ${SCRIPT_PATH}/login_information.txt
else
echo "WordpressScriptPath = ${MYDOMAIN}/${WORDPRESSPATHNAME}" >> ${SCRIPT_PATH}/login_information.txt
fi
echo "" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt
}
