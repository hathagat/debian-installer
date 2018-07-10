#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

deinstall_phpmyadmin() {

mysql -u root -p${MYSQL_ROOT_PASS} -e "DROP DATABASE IF EXISTS phpmyadmin;"  

rm -rf /usr/local/phpmyadmin/
rm ${SCRIPT_PATH}/phpmyadmin_login_data.txt
rm /etc/nginx/_phpmyadmin.conf
sed -i "s/include _phpmyadmin.conf;/#include _phpmyadmin.conf;/g" /etc/nginx/sites-available/${MYDOMAIN}.conf

systemctl -q restart php$PHPVERSION7-fpm.service
service nginx restart
}
