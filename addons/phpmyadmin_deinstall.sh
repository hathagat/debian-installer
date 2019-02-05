#!/bin/bash
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

deinstall_phpmyadmin() {

trap error_exit ERR

MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" ${SCRIPT_PATH}/login_information.txt)
mysql -u root -p${MYSQL_ROOT_PASS} -e "DROP DATABASE IF EXISTS phpmyadmin;"

rm -rf /usr/local/phpmyadmin/
rm ${SCRIPT_PATH}/phpmyadmin_login_data.txt
rm /etc/nginx/_phpmyadmin.conf
sed -i "s/include _phpmyadmin.conf;/#include _phpmyadmin.conf;/g" /etc/nginx/sites-available/${MYDOMAIN}.conf

systemctl -q restart php$PHPVERSION7-fpm.service
service nginx restart

sed -i 's/PMA_IS_INSTALLED="1"/PMA_IS_INSTALLED="0"/' ${SCRIPT_PATH}/configs/userconfig.cfg
}
