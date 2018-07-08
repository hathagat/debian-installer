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

cp ${SCRIPT_PATH}/addons/vhosts/munin.conf /etc/nginx/_monit.conf
sed -i "s/#include _monit;/include _monit.conf;/g" /etc/nginx/sites-available/${MYDOMAIN}.conf

ln -s /etc/monit/conf-available/openssh-server /etc/monit/conf-enabled/
ln -s /etc/monit/conf-available/nginx /etc/monit/conf-enabled/
ln -s /etc/monit/conf-available/mysql /etc/monit/conf-enabled/
ln -s /etc/monit/conf-available/postfix /etc/monit/conf-enabled/
ln -s /etc/monit/conf-available/cron /etc/monit/conf-enabled/
ln -s /etc/monit/conf-available/rsyslog /etc/monit/conf-enabled/
ln -s /etc/monit/conf-available/smartmontools /etc/monit/conf-enabled/

systemctl restart monit
service nginx reload

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "Monit Address: ${MYDOMAIN}/monit/" >> ${SCRIPT_PATH}/login_information.txt
echo "MONIT_ADMIN_USER = ${MONIT_ADMIN_USER}" >> ${SCRIPT_PATH}/login_information.txt
echo "MONIT_ADMIN_PASSWORD = ${MONIT_ADMIN_PASSWORD}" >> ${SCRIPT_PATH}/login_information.txt
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt
}
