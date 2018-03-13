#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
# thx to https://gist.github.com/bgallagh3r
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

#WORDPRESSPATHNAME="rootpath"

    ;;

  4)
      while true
        do
          WORDPRESSPATHNAME=$(dialog --clear \
          --backtitle "$BACKTITLE" \
          --inputbox "Enter the name of Wordpress installation path. Link after ${MYDOMAIN}/ only A-Z and a-z letters" \
          $HEIGHT $WIDTH \
          3>&1 1>&2 2>&3 3>&- \
          )
            if [[ "$WORDPRESSPATHNAME" =~ [^0-9A-Za-z]+ ]];then
              break
            else
              dialog --title "Your Wordpress path" --msgbox "[ERROR] You should read it properly!" $HEIGHT $WIDTH
              dialog --clear
            fi
        done
    ;;
esac

# Set vars
# Maybe the user should not shoose an user and db name....
WORDPRESS_USER=$(username)
WORDPRESS_DB_NAME=$(username)
WORDPRESS_DB_PASS=$(password)
WORDPRESS_DB_PREFIX=$(username)

MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" /root/NeXt-Server/login_information.txt)

#echo ${MYSQL_ROOT_PASS}

mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE DATABASE ${WORDPRESS_DB_NAME};"
mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE USER ${WORDPRESS_USER}@localhost IDENTIFIED BY '${WORDPRESS_DB_PASS}';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "GRANT ALL PRIVILEGES ON ${WORDPRESS_DB_NAME}.* TO '${WORDPRESS_USER}'@'localhost';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "FLUSH PRIVILEGES;"

cd /etc/nginx/html/${MYDOMAIN}/

wget --tries=42 https://wordpress.org/latest.tar.gz
tar -zxvf latest.tar.gz

if [ -z "${WORDPRESSPATHNAME}" ]; then

cd wordpress
#copy file to parent dir
cp -rf . ..

#move back to parent dir
cd ..

#remove files from wordpress folder
rm -R wordpress

fi


if [ -z "${WORDPRESSPATHNAME}" ]; then
# i hope some day im fixed.... ;(
echo "fix me please" > /dev/null
else
mv /etc/nginx/html/${MYDOMAIN}/wordpress /etc/nginx/html/${MYDOMAIN}/${WORDPRESSPATHNAME}
cd ${WORDPRESSPATHNAME}
fi


cp wp-config-sample.php wp-config.php




# Set Path wp-Config
if [ -z "${WORDPRESSPATHNAME}" ]; then
WPCONFIGFILE="/etc/nginx/html/${MYDOMAIN}/wp-config.php"
else
WPCONFIGFILE="/etc/nginx/html/${MYDOMAIN}/${WORDPRESSPATHNAME}/wp-config.php"
fi

# Change prefix random
sed -i "s/wp_/${WORDPRESS_DB_PREFIX}_/g"  ${WPCONFIGFILE}

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

if [ -z "${WORDPRESSPATHNAME}" ]; then
mkdir /etc/nginx/html/${MYDOMAIN}/wp-content/uploads
cd /etc/nginx/html/${MYDOMAIN}/
chown www-data:www-data -R /etc/nginx/html/${MYDOMAIN}
else
mkdir /etc/nginx/html/${MYDOMAIN}/${WORDPRESSPATHNAME}/wp-content/uploads
cd /etc/nginx/html/${MYDOMAIN}/${WORDPRESSPATHNAME}/
chown www-data:www-data -R /etc/nginx/html/${MYDOMAIN}/${WORDPRESSPATHNAME}
fi


find . -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;

# Maybe better add in /etc/nginx/site-enabled/....
if [ -z "${WORDPRESSPATHNAME}" ]; then # then is root path
  # Search for "option" then /a for new line and add "insert text here"
  #sed '/option/a insert text here' /etc/nginx/sites-available/${MYDOMAIN}.conf
  #try_files \$uri \$uri/ /index.php?\$args;
  sed -i "s/#try_files/try_files/g" /etc/nginx/sites-available/${MYDOMAIN}.conf
  cp ${SCRIPT_PATH}/addons/vhosts/wordpress-normal.conf /etc/nginx/sites-custom/wordpress.conf

else # then is custom path

  cp ${SCRIPT_PATH}/addons/vhosts/wordpress-custom.conf /etc/nginx/sites-custom/wordpress.conf
  sed -i "s/WORDPRESSPATHNAME/${WORDPRESSPATHNAME}/g"  /etc/nginx/sites-custom/wordpress.conf
  # Add harding for custom path
fi

systemctl reload nginx

dialog --backtitle "NeXt Server Installation" --msgbox "Visit ${MYDOMAIN}/${WORDPRESSPATHNAME} to finish the installation" $HEIGHT $WIDTH

echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information.txt
echo "Wordpress" >> ${SCRIPT_PATH}/login_information.txt
echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information.txt
echo "https://${MYDOMAIN}/${WORDPRESSPATHNAME}" >> ${SCRIPT_PATH}/login_information.txt
echo "WordpressDBUser = ${WORDPRESS_USER}" >> ${SCRIPT_PATH}/login_information.txt
echo "WordpressDBName = ${WORDPRESS_DB_NAME}" >> ${SCRIPT_PATH}/login_information.txt
echo "WordpressDBPassword = ${WORDPRESS_DB_PASS}" >> ${SCRIPT_PATH}/login_information.txt
if [ -z "${WORDPRESSPATHNAME}" ]; then
echo "WordpressScriptPath = ${MYDOMAIN}" >> ${SCRIPT_PATH}/login_information.txt
else
echo "WordpressScriptPath = ${MYDOMAIN}/${WORDPRESSPATHNAME}" >> ${SCRIPT_PATH}/login_information.txt
fi
echo "" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt

}


deinstall_wordpress() {
set -x
rm -rf /etc/nginx/html/wordpress

MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" /root/NeXt-Server/login_information.txt)
WORDPRESS_DB_NAME=$(grep -Pom 1 "(?<=^WordpressDBName = ).*$" /root/NeXt-Server/login_information.txt)
WordpressDBUser=$(grep -Pom 1 "(?<=^WordpressDBUser = ).*$" /root/NeXt-Server/login_information.txt)
WordpressScriptPath=$(grep -Pom 1 "(?<=^WordpressScriptPath = ).*$" /root/NeXt-Server/login_information.txt)


mysql -u root -p${MYSQL_ROOT_PASS} -e "DROP DATABASE IF EXISTS ${WORDPRESS_DB_NAME};"
mysql -u root -p${MYSQL_ROOT_PASS} -e "DROP USER ${WordpressDBUser}@localhost;"
rm -rf /etc/nginx/html/${WordpressScriptPath}
rm -rf /etc/nginx/sites-custom/wordpress.conf

mkdir /etc/nginx/html/${MYDOMAIN}
cp ${SCRIPT_PATH}/NeXt-logo.jpg /etc/nginx/html/${MYDOMAIN}/
cp ${SCRIPT_PATH}/configs/nginx/index.html /etc/nginx/html/${MYDOMAIN}/index.html

}
