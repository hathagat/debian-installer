#!/bin/bash

install_munin() {

set -x

install_packages "munin munin-node munin-plugins-extra apache2-utils"

MUNIN_HTTPAUTH_PASS=$(password)
htpasswd -b /etc/nginx/htpasswd/.htpasswd ${MUNIN_HTTPAUTH_USER} ${MUNIN_HTTPAUTH_PASS} >>"${main_log}" 2>>"${err_log}"

cp ${SCRIPT_PATH}/addons/vhosts/munin.conf /etc/nginx/sites-custom/munin.conf

if [[ ${USE_PHP5} == '1' ]]; then
	sed -i 's/fastcgi_pass unix:\/var\/run\/php\/php7.1-fpm.sock\;/fastcgi_pass unix:\/var\/run\/php5-fpm.sock\;/g' /etc/nginx/sites-custom/munin.conf
fi

if [[ ${USE_PHP7_2} == '1' ]]; then
	sed -i 's/fastcgi_pass unix:\/var\/run\/php\/php7.1-fpm.sock\;/fastcgi_pass unix:\/var\/run\/php\/php7.2-fpm.sock\;/g' /etc/nginx/sites-custom/munin.conf
fi

#sed -i "s/INSERT_SERVER_IP/${IPADDR}/g" /etc/nginx/sites-custom/munin.conf
sed -i "s/localhost.localdomain/mail.${MYDOMAIN}/g" /etc/munin/munin.conf

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "Munin Address: ${MYDOMAIN}/munin/" >> ${SCRIPT_PATH}/login_information.txt
echo "MUNIN_HTTPAUTH_USER = ${MUNIN_HTTPAUTH_USER}" >> ${SCRIPT_PATH}/login_information.txt
echo "MUNIN_HTTPAUTH_PASS = ${MUNIN_HTTPAUTH_PASS}" >> ${SCRIPT_PATH}/login_information.txt
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt

service munin-node restart
service nginx restart
}
