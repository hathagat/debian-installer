#!/bin/bash
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_rainloop() {

trap error_exit ERR

install_packages "apache2-utils"

RAIN_HTTPAUTH_USER=$(username)
RAIN_HTTPAUTH_PASS=$(password)

#for storing contacts in a db
mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE DATABASE rainloop;"

RAINLOOP_VERSION="rainloop-community-latest"

mkdir -p /var/www/${MYDOMAIN}/public/webmail
cd /var/www/${MYDOMAIN}/public/
wget_tar "https://www.rainloop.net/repository/webmail/${RAINLOOP_VERSION}.zip"
unzip_file "${RAINLOOP_VERSION}.zip -d /var/www/${MYDOMAIN}/public/webmail"
rm ${RAINLOOP_VERSION}.zip

cd /var/www/${MYDOMAIN}/public/webmail
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
chown -R www-data:www-data .

htpasswd -b /etc/nginx/htpasswd/.htpasswd ${RAIN_HTTPAUTH_USER} ${RAIN_HTTPAUTH_PASS}

RAINLOOP_ADMIN_USER="admin"
RAINLOOP_ADMIN_PASSWORD="12345"

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "RAIN_HTTPAUTH_USER = ${RAIN_HTTPAUTH_USER}" >> ${SCRIPT_PATH}/login_information.txt
echo "RAIN_HTTPAUTH_PASS = ${RAIN_HTTPAUTH_PASS}" >> ${SCRIPT_PATH}/login_information.txt
echo "Disable the http auth?" >> ${SCRIPT_PATH}/login_information.txt
echo "Login to the Rainloop admin panel (https://${MYDOMAIN}/webmail/?admin) and change the standard password (12345)!" >> ${SCRIPT_PATH}/login_information.txt
echo "After that open /etc/nginx/sites-available/${MYDOMAIN}.conf and delete the lines:" >> ${SCRIPT_PATH}/login_information.txt
echo "location /webmail/ {" >> ${SCRIPT_PATH}/login_information.txt
echo 'auth_basic "Restricted";' >> ${SCRIPT_PATH}/login_information.txt
echo "}" >> ${SCRIPT_PATH}/login_information.txt
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "Rainloop Admin URL: https://${MYDOMAIN}/webmail/?admin" >> ${SCRIPT_PATH}/login_information.txt
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "Rainloop Admin - Login: ${RAINLOOP_ADMIN_USER}" >> ${SCRIPT_PATH}/login_information.txt
echo "Rainloop Admin - Password: ${RAINLOOP_ADMIN_PASSWORD}" >> ${SCRIPT_PATH}/login_information.txt
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "Rainloop Webmail URL: https://${MYDOMAIN}/webmail/" >> ${SCRIPT_PATH}/login_information.txt
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt
}
