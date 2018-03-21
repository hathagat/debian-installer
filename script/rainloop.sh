#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_rainloop() {

mkdir -p /etc/nginx/html/${MYDOMAIN}/webmail
cd /etc/nginx/html/${MYDOMAIN}/
wget --no-check-certificate https://www.rainloop.net/repository/webmail/rainloop-latest.zip --tries=3 >>"${main_log}" 2>>"${err_log}"
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: rainloop-latest.zip download failed."
      exit
    fi

unzip rainloop-latest.zip -d /etc/nginx/html/${MYDOMAIN}/webmail >>"${main_log}" 2>>"${err_log}"
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: rainloop-latest.zip is corrupted."
      exit
    fi
rm rainloop-latest.zip

cd /etc/nginx/html/${MYDOMAIN}/webmail
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
chown -R www-data:www-data .

COMPLETEDOMAIN="https://${MYDOMAN}/webmail/?admin"
# Maybe request GET is enough
if curl -s --head  --request GET ${COMPLETEDOMAIN} | grep "HTTP/2 200" > /dev/null 2>&1; then
	 #echo "${MYDOMAN} is UP"
	 # make the config for rainloop
	 curl -s ${COMPLETEDOMAIN} > /dev/null 2>&1
else
	check_service "nginx"
fi
wget ${MYDOMAIN}/webmail/?admin
#curl --user admin:12345 ${COMPLETEDOMAIN} -v 
#if [ ! -f /etc/nginx/html/${MYDOMAN}/webmail/data/_data_/_default_/configs/application.ini ]; then 
#curl ${COMPLETEDOMAIN}
#fi

if [ ! -f /etc/nginx/html/${MYDOMAN}/webmail/data/_data_/_default_/configs/application.ini ]; then 
echo "Rainloop default login...." >> /root/rainloop.txt
fi


# Now copy config application.ini :)
cp ${SCRIPT_PATH}/configs/rainloop/application.ini /etc/nginx/html/${MYDOMAN}/webmail/data/_data_/_default_/configs/application.ini
RAINLOOP_ADMIN_PASSWORD=$(password)
RAINLOOP_ADMIN_USER=$(username)
sed -i "s/RAINLOOP_ADMIN_PASSWORD/${RAINLOOP_ADMIN_PASSWORD}/g" /etc/nginx/html/${MYDOMAIN}/webmail/data/_data_/_default_/configs/application.ini
sed -i "s/RAINLOOP_ADMIN_USER/${RAINLOOP_ADMIN_USER}/g" /etc/nginx/html/${MYDOMAIN}/webmail/data/_data_/_default_/configs/application.ini

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "Rainloop Admin URL: https://${MYDOMAIN}/webmail/?admin" >> ${SCRIPT_PATH}/login_information.txt
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "Rainloop Admin - Login: ${RAINLOOP_ADMIN_USER}" >> ${SCRIPT_PATH}/login_information.txt
echo "Rainloop Admin - Password: ${RAINLOOP_ADMIN_PASSWORT}" >> ${SCRIPT_PATH}/login_information.txt
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "Rainloop Webmail URL: https://${MYDOMAIN}/webmail/" >> ${SCRIPT_PATH}/login_information.txt
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt

}
