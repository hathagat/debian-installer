#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script! 
#-------------------------------------------------------------------------------------------------------------

install_wordpress() {

  # --- MYDOMAIN ---
  source ${SCRIPT_PATH}/script/functions.sh; get_domain

  CHOICE_HEIGHT=2
  MENU="Is this the domain, you want to use? ${DETECTED_DOMAIN}:"
  OPTIONS=(1 "Yes"
  		     2 "No")
  menu
  clear
  case $CHOICE in
        1)
  			MYDOMAIN=${DETECTED_DOMAIN}
              ;;
  		2)
  			while true
  				do
  					MYDOMAIN=$(dialog --clear \
  					--backtitle "$BACKTITLE" \
  					--inputbox "Enter your Domain without http:// (exmaple.org):" \
  					$HEIGHT $WIDTH \
  					3>&1 1>&2 2>&3 3>&- \
  					)
  						if [[ "$MYDOMAIN" =~ $CHECK_DOMAIN ]];then
  							break
  						else
  							dialog --title "NeXt Server Confighelper" --msgbox "[ERROR] Should we again practice how a Domain address looks?" $HEIGHT $WIDTH
  							dialog --clear
  						fi
  				done
              ;;
  esac

#Set vars
# Mybe the user should not shoose an user and db name....
WORDPRESS_USER="NXTWORDPRESSUSER"
WORDPRESS_DB_NAME="NXTWORDPRESSDB"


WORDPRESS_DB_PASS=$(password)

# Get root PW
MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" /root/NeXt-Server/login_information)
#echo "${MYSQL_ROOT_PASS}"


#Ceate new DB User and DB
mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE DATABASE ${WORDPRESS_DB_NAME};"
mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE USER '${WORDPRESS_USER}'@'localhost' IDENTIFIED BY '${WORDPRESS_DB_PASS}';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "GRANT ALL PRIVILEGES ON ${WORDPRESS_DB_NAME} . * TO '${WORDPRESS_USER}'@'localhost';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "FLUSH PRIVILEGES;"

cd /etc/nginx/html/${MYDOMAIN}/

wget https://wordpress.org/latest.tar.gz >>"${make_log}" 2>>"${make_err_log}" || error_exit "Failed to get Wordpress"

tar -zxvf latest.tar.gz >>"${make_log}" 2>>"${make_err_log}" || error_exit "Failed to tar wordpress"
cd wordpress
cp -rf . ..
cd ..
rm -R wordpress
cp wp-config-sample.php wp-config.php

#set database details with perl find and replace
sed -e "s/database_name_here/${WORDPRESS_DB_NAME}/g" /etc/nginx/html/${MYDOMAIN}/wp-config.php >>"${make_log}" 2>>"${make_err_log}" || error_exit "Failed to sed db name"
sed -e "s/username_here/${WORDPRESS_USER}/g" /etc/nginx/html/${MYDOMAIN}/wp-config.php >>"${make_log}" 2>>"${make_err_log}" || error_exit "Failed to sed user name"
sed -e "s/password_here/${WORDPRESS_DB_PASS}/g" /etc/nginx/html/${MYDOMAIN}/wp-config.php >>"${make_log}" 2>>"${make_err_log}" || error_exit "Failed to sed db pass"

# Get salts
SALTS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/) >>"${make_log}" 2>>"${make_err_log}" || error_exit "Failed to get salt"
while read -r SALT; do
search="define('$(echo "$SALT" | cut -d "'" -f 2)"
replace=$(echo "$SALT" | cut -d "'" -f 4)
sed -i "/^$search/s/put your unique phrase here/$(echo $replace | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')/" /etc/nginx/html/${MYDOMAIN}/wp-config.php
done <<< "$SALTS"


mkdir /etc/nginx/html/${MYDOMAIN}/wp-content/uploads

cd /etc/nginx/html/${MYDOMAIN}/
chown www-data:www-data -R /etc/nginx/html/${MYDOMAIN}/
find . -type d -exec chmod 755 {} /etc/nginx/html/${MYDOMAIN}/;
find . -type f -exec chmod 644 {} /etc/nginx/html/${MYDOMAIN}/;

echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information
echo "-wordpress" >> ${SCRIPT_PATH}/login_information
echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information
echo "https://${MYDOMAIN}/" >> ${SCRIPT_PATH}/login_information
echo "DBUsername = ${WORDPRESS_USER}" >> ${SCRIPT_PATH}/login_information
echo "DBName = ${WORDPRESS_DB_NAME}" >> ${SCRIPT_PATH}/login_information
echo "WordpressDBPassword = ${WORDPRESS_DB_PASS}" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information



}
