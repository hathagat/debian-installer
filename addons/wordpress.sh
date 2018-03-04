#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_wordpress() {
set -x

# --- MYDOMAIN ---
source ${SCRIPT_PATH}/script/functions.sh; get_domain

CHOICE_HEIGHT=4
MENU="In wich path you want to install Wordpress?"
OPTIONS=(1 "${MYDOMAIN}/wordpress"
2 "${MYDOMAIN}/blog"
3 "root of ${MYDOMAIN}"
4 "custom")
menu
clear

case $CHOICE in
  1)
    WORDPRESSPATHNAME="wordpress"
    ;;

  2)
    WORDPRESSPATHNAME="blog"
    ;;

  3)
    WORDPRESSPATHNAME=""
    ;;

  4)
    WORDPRESSPATHNAME=$(dialog --clear \
    --backtitle "$BACKTITLE" \
    --inputbox "Enter the name of Wordpress installation path. Link after ${MYDOMAIN}/" \
    $HEIGHT $WIDTH \
    3>&1 1>&2 2>&3 3>&- \
    )
    ;;
esac

# Set vars
# Maybe the user should not shoose an user and db name....
WORDPRESS_USER="NXTWORDPRESSUSER"
WORDPRESS_DB_NAME="NXTWORDPRESSDB"
WORDPRESS_DB_PASS=$(password)

MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" /root/NeXt-Server/login_information)

echo ${MYSQL_ROOT_PASS}

mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE DATABASE ${WORDPRESS_DB_NAME};"
mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE USER ${WORDPRESS_USER}@localhost IDENTIFIED BY '${WORDPRESS_DB_PASS}';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "GRANT ALL PRIVILEGES ON ${WORDPRESS_DB_NAME}.* TO '${WORDPRESS_USER}'@'localhost';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "FLUSH PRIVILEGES;"

cd /etc/nginx/html/${MYDOMAIN}/

wget --tries=42 https://wordpress.org/latest.tar.gz
tar -zxvf latest.tar.gz

mv /etc/nginx/html/${MYDOMAIN}/wordpress /etc/nginx/html/${MYDOMAIN}/${WORDPRESSPATHNAME}

cd ${WORDPRESSPATHNAME}
cp wp-config-sample.php wp-config.php

# Set Path wp-Config
WPCONFIGFILE="/etc/nginx/html/${MYDOMAIN}/${WORDPRESSPATHNAME}/wp-config.php"

#set database details - find and replace
sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/g"  ${WPCONFIGFILE}
sed -i "s/username_here/${WORDPRESS_USER}/g"  ${WPCONFIGFILE}
sed -i "s/password_here/${WORDPRESS_DB_PASS}/g"  ${WPCONFIGFILE}

# Get salts
salts=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
while read -r salt; do
  search="define('$(echo "$salt" | cut -d "'" -f 2)"
  replace=$(echo "$salt" | cut -d "'" -f 4)
    sed -i "/^$search/s/put your unique phrase here/$(echo $replace | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')/" ${WPCONFIGFILE}
done <<< "$salts"

mkdir /etc/nginx/html/${MYDOMAIN}/${WORDPRESSPATHNAME}/wp-content/uploads

cd /etc/nginx/html/${MYDOMAIN}/${WORDPRESSPATHNAME}/
chown www-data:www-data -R /etc/nginx/html/${MYDOMAIN}/${WORDPRESSPATHNAME}
find . -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;

cat > /etc/nginx/sites-custom/wordpress.conf <<END
location /${WORDPRESSPATHNAME}/ {
 try_files $uri $uri/ /${WORDPRESSPATHNAME}/index.php?$args;
}
END

dialog --backtitle "NeXt Server Installation" --msgbox "Visit ${MYDOMAIN}/${WORDPRESSPATHNAME} to finish the installation" $HEIGHT $WIDTH

echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information
echo "Wordpress" >> ${SCRIPT_PATH}/login_information
echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information
echo "https://${MYDOMAIN}/${WORDPRESSPATHNAME}" >> ${SCRIPT_PATH}/login_information
echo "DBUsername = ${WORDPRESS_USER}" >> ${SCRIPT_PATH}/login_information
echo "DBName = ${WORDPRESS_DB_NAME}" >> ${SCRIPT_PATH}/login_information
echo "WordpressDBPassword = ${WORDPRESS_DB_PASS}" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information

service nginx restart

}
