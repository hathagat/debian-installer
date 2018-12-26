#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_munin() {

set -x

install_packages "munin munin-node munin-plugins-extra apache2-utils"

MUNIN_HTTPAUTH_PASS=$(password)
htpasswd -b /etc/nginx/htpasswd/.htpasswd ${MUNIN_HTTPAUTH_USER} ${MUNIN_HTTPAUTH_PASS} >>"${main_log}" 2>>"${err_log}"

cp ${SCRIPT_PATH}/addons/vhosts/_munin.conf /etc/nginx/_munin.conf
sed -i "s/#include _munin.conf;/include _munin.conf;/g" /etc/nginx/sites-available/${MYDOMAIN}.conf

if [[ ${USE_PHP7_2} == '1' ]]; then
	sed -i "s/php7.1/php7.2/g" /etc/nginx/_munin.conf
fi

sed -i "s/localhost.localdomain/mail.${MYDOMAIN}/g" /etc/munin/munin.conf

systemctl -q restart php$PHPVERSION7-fpm.service
service munin-node restart
service nginx restart

touch ${SCRIPT_PATH}/munin_login_data.txt
echo "--------------------------------------------" >> ${SCRIPT_PATH}/munin_login_data.txt
echo "Munin" >> ${SCRIPT_PATH}/munin_login_data.txt
echo "--------------------------------------------" >> ${SCRIPT_PATH}/munin_login_data.txt
echo "Munin Address: ${MYDOMAIN}/munin/" >> ${SCRIPT_PATH}/munin_login_data.txt
echo "MUNIN_HTTPAUTH_USER = ${MUNIN_HTTPAUTH_USER}" >> ${SCRIPT_PATH}/munin_login_data.txt
echo "MUNIN_HTTPAUTH_PASS = ${MUNIN_HTTPAUTH_PASS}" >> ${SCRIPT_PATH}/munin_login_data.txt

sed -i 's/MUNIN_IS_INSTALLED="0"/MUNIN_IS_INSTALLED="1"/' ${SCRIPT_PATH}/configs/userconfig.cfg

dialog_msg "Please save the shown login information on next page"
cat ${SCRIPT_PATH}/munin_login_data.txt
source ${SCRIPT_PATH}/script/functions.sh; continue_or_exit
}
