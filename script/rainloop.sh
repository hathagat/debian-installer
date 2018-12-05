#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_rainloop() {

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

RAINLOOP_ADMIN_USER="admin"
RAINLOOP_ADMIN_PASSWORD="12345"

#RAINLOOP_ADMIN_PASSWORD=$(password)
#RAINLOOP_ADMIN_USER=$(username)
#find /etc/nginx/html/${MYDOMAIN}/ -name 'Application.php' -exec sed -i "s/array('12345')/array('${RAINLOOP_ADMIN_PASSWORD}')/" {} \;
#find /etc/nginx/html/${MYDOMAIN}/ -name 'Application.php' -exec sed -i "s/array('admin', 'Login and password for web admin panel')/array('${RAINLOOP_ADMIN_USER}', 'Login and password for web admin panel')/" {} \;

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
