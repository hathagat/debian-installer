#!/bin/bash

install_rainloop() {

# Community Edition commercial possible without auto updater
RAINLOOP_VERSION="rainloop-community-latest"

# BASIS Edition only non commercial with auto updateer
#RAINLOOP_VERSION="rainloop-latest"

mkdir -p /etc/nginx/html/${MYDOMAIN}/webmail
cd /etc/nginx/html/${MYDOMAIN}/
#wget --no-check-certificate https://www.rainloop.net/repository/webmail/${RAINLOOP_VERSION}.zip --tries=3 >>"${main_log}" 2>>"${err_log}"
wget_tar "https://www.rainloop.net/repository/webmail/${RAINLOOP_VERSION}.zip"
unzip_file "${RAINLOOP_VERSION}.zip -d /etc/nginx/html/${MYDOMAIN}/webmail"
rm ${RAINLOOP_VERSION}.zip

cd /etc/nginx/html/${MYDOMAIN}/webmail
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
