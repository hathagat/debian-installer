#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_monit() {
MONIT_ADMIN_PASSWORD=$(password)
MONIT_ADMIN_USER=$(username)

install_packages "monit"

systemctl start monit
systemctl enable monit

sed -i "s/# set httpd port 2812 and/set httpd port 2812 and/g" /etc/monit/monitrc
sed -i "s/# allow admin:monit/allow admin:monit/g" /etc/monit/monitrc
sed -i "s/allow admin:monit/allow ${MONIT_ADMIN_USER}:${MONIT_ADMIN_PASSWORD}/g" /etc/monit/monitrc

cp ${SCRIPT_PATH}/addons/vhosts/_monit.conf /etc/nginx/_monit.conf
sed -i "s/#include _monit;/include _monit.conf;/g" /etc/nginx/sites-available/${MYDOMAIN}.conf

ln -s /etc/monit/conf-available/openssh-server /etc/monit/conf-enabled/
ln -s /etc/monit/conf-available/nginx /etc/monit/conf-enabled/
ln -s /etc/monit/conf-available/mysql /etc/monit/conf-enabled/
ln -s /etc/monit/conf-available/postfix /etc/monit/conf-enabled/
ln -s /etc/monit/conf-available/cron /etc/monit/conf-enabled/
ln -s /etc/monit/conf-available/rsyslog /etc/monit/conf-enabled/
ln -s /etc/monit/conf-available/smartmontools /etc/monit/conf-enabled/

systemctl -q restart php$PHPVERSION7-fpm.service
systemctl restart monit
service nginx reload

touch ${SCRIPT_PATH}/monit_login_data.txt
echo "--------------------------------------------" >> ${SCRIPT_PATH}/monit_login_data.txt
echo "Monit" >> ${SCRIPT_PATH}/monit_login_data.txt
echo "--------------------------------------------" >> ${SCRIPT_PATH}/monit_login_data.txt
echo "Monit Address: ${MYDOMAIN}/monit/" >> ${SCRIPT_PATH}/monit_login_data.txt
echo "MONIT_ADMIN_USER = ${MONIT_ADMIN_USER}" >> ${SCRIPT_PATH}/monit_login_data.txt
echo "MONIT_ADMIN_PASSWORD = ${MONIT_ADMIN_PASSWORD}" >> ${SCRIPT_PATH}/monit_login_data.txt

dialog_msg "Please save the shown login information on next page"
cat ${SCRIPT_PATH}/monit_login_data.txt
source ${SCRIPT_PATH}/script/functions.sh; continue_or_exit
}
