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
sed -i "s/wp_/${WORDPRESS_DB_PREFIX}/g"  ${WPCONFIGFILE}

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
if [ -z "${WORDPRESSPATHNAME}" ]; then
  # Search for "option" then /a for new line and add "insert text here"
  #sed '/option/a insert text here' /etc/nginx/sites-available/${MYDOMAIN}.conf
  #try_files \$uri \$uri/ /index.php?\$args;

  sed -i "s/#try_files/try_files/g" /etc/nginx/sites-available/${MYDOMAIN}.conf
else
  cat > /etc/nginx/sites-custom/wordpress.conf <<END
  location /${WORDPRESSPATHNAME}/ {
   try_files $uri $uri/ /${WORDPRESSPATHNAME}/index.php?$args;
  }

  # allow AJAX requests in themes and plugins
location ~ ^/wp-admin/admin-ajax.php$ { allow all; include /usr/local/nginx/conf/php.conf; }

#Deny access to wp-content folders for suspicious files
location ~* ^/(wp-content)/(.*?)\.(zip|gz|tar|bzip2|7z)\$ { deny all; }
location ~ ^/wp-content/uploads/sucuri { deny all; }
location ~ ^/wp-content/updraft { deny all; }

# Block nginx-help log from public viewing
location ~* /wp-content/uploads/nginx-helper/ { deny all; }
location ~ ^/(wp-includes/js/tinymce/wp-tinymce.php) {
  include /usr/local/nginx/conf/php.conf;

}
# Deny access to any files with a .php extension in the uploads directory
# Works in sub-directory installs and also in multisite network
location ~* /(?:uploads|files)/.*\.php\$ { deny all; }

# Deny access to uploads that aren’t images, videos, music, etc.
location ~* ^/wp-content/uploads/.*.(html|htm|shtml|php|js|swf|css)$ {
    deny all;
}

# Whitelist Exception for https://wordpress.org/plugins/onesignal-free-web-push-notifications//
location ~ ^/wp-content/plugins/onesignal-free-web-push-notifications/ {
  include /usr/local/nginx/conf/php.conf;
}
# Whitelist Exception for https://wordpress.org/plugins/sparkpost/
location ~ ^/wp-content/plugins/sparkpost/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/sendgrid-email-delivery-simplified/
location ~ ^/wp-content/plugins/sendgrid-email-delivery-simplified/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/mailgun/
location ~ ^/wp-content/plugins/mailgun/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/mailjet-for-wordpress/
location ~ ^/wp-content/plugins/mailjet-for-wordpress/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/easy-wp-smtp/
location ~ ^/wp-content/plugins/easy-wp-smtp/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/postman-smtp/
location ~ ^/wp-content/plugins/postman-smtp/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/sendpress/
location ~ ^/wp-content/plugins/sendpress/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/wp-mail-bank/
location ~ ^/wp-content/plugins/wp-mail-bank/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/theme-check/
location ~ ^/wp-content/plugins/theme-check/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/woocommerce/
location ~ ^/wp-content/plugins/woocommerce/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/woocommerce-csvimport/
location ~ ^/wp-content/plugins/woocommerce-csvimport/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/advanced-custom-fields/
location ~ ^/wp-content/plugins/advanced-custom-fields/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/contact-form-7/
location ~ ^/wp-content/plugins/contact-form-7/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/duplicator/
location ~ ^/wp-content/plugins/duplicator/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/jetpack/
location ~ ^/wp-content/plugins/jetpack/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/nextgen-gallery/
location ~ ^/wp-content/plugins/nextgen-gallery/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/tinymce-advanced/
location ~ ^/wp-content/plugins/tinymce-advanced/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/updraftplus/
location ~ ^/wp-content/plugins/updraftplus/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/wordpress-importer/
location ~ ^/wp-content/plugins/wordpress-importer/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/wordpress-seo/
location ~ ^/wp-content/plugins/wordpress-seo/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/wpclef/
location ~ ^/wp-content/plugins/wpclef/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/mailchimp-for-wp/
location ~ ^/wp-content/plugins/mailchimp-for-wp/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/wp-optimize/
location ~ ^/wp-content/plugins/wp-optimize/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/si-contact-form/
location ~ ^/wp-content/plugins/si-contact-form/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/akismet/
location ~ ^/wp-content/plugins/akismet/ {
  location ~ ^/wp-content/plugins/akismet/(.+/)?(form|akismet)\.(css|js)\$ { allow all; }
  location ~ ^/wp-content/plugins/akismet/(.+/)?(.+)\.(png|gif)\$ { allow all; }
  location ~* /wp-content/plugins/akismet/akismet/.*\.php\$ {
    include /usr/local/nginx/conf/php.conf;
    allow 127.0.0.1;
    deny all;
  }
}
# Whitelist Exception for https://wordpress.org/plugins/bbpress/
location ~ ^/wp-content/plugins/bbpress/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/buddypress/
location ~ ^/wp-content/plugins/buddypress/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/all-in-one-seo-pack/
location ~ ^/wp-content/plugins/all-in-one-seo-pack/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/google-analytics-for-wordpress/
location ~ ^/wp-content/plugins/google-analytics-for-wordpress/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/regenerate-thumbnails/
location ~ ^/wp-content/plugins/regenerate-thumbnails/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/wp-pagenavi/
location ~ ^/wp-content/plugins/wp-pagenavi/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/wordfence/
location ~ ^/wp-content/plugins/wordfence/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/really-simple-captcha/
location ~ ^/wp-content/plugins/really-simple-captcha/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/wp-pagenavi/
location ~ ^/wp-content/plugins/wp-pagenavi/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/ml-slider/
location ~ ^/wp-content/plugins/ml-slider/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/black-studio-tinymce-widget/
location ~ ^/wp-content/plugins/black-studio-tinymce-widget/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/disable-comments/
location ~ ^/wp-content/plugins/disable-comments/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/better-wp-security/
location ~ ^/wp-content/plugins/better-wp-security/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for http://wlmsocial.com/
location ~ ^/wp-content/plugins/wlm-social/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for mediagrid timthumb
location ~ ^/wp-content/plugins/media-grid/classes/ {
  include /usr/local/nginx/conf/php.conf;

}
# Whitelist Exception for https://wordpress.org/plugins/sparkpost/
location ~ ^/wp-content/plugins/comet-cache/ {
  include /usr/local/nginx/conf/php.conf;

}
# Block PHP files in content directory.
location ~* /wp-content/.*\.php\$ {
  deny all;
}
# Block PHP files in includes directory.
location ~* /wp-includes/.*\.php\$ {
  deny all;
}
# Block PHP files in uploads, content, and includes directory.
location ~* /(?:uploads|files|wp-content|wp-includes)/.*\.php\$ {
  deny all;
}
# Make sure files with the following extensions do not get loaded by nginx because nginx would display the source code, and these files can contain PASSWORDS!
location ~* \.(engine|inc|info|install|make|module|profile|test|po|sh|.*sql|theme|tpl(\.php)?|xtmpl)\$|^(\..*|Entries.*|Repository|Root|Tag|Template)\$|\.php_
{
return 444;
}
#nocgi
location ~* \.(pl|cgi|py|sh|lua)\$ {
return 444;
}
#disallow
location ~* (w00tw00t) {
return 444;
}
location ~* /(\.|wp-config\.php|wp-config\.txt|changelog\.txt|readme\.txt|readme\.html|license\.txt) { deny all; }
END

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
WordpressDBName=$(grep -Pom 1 "(?<=^WordpressDBName = ).*$" /root/NeXt-Server/login_information.txt)
WordpressDBUser=$(grep -Pom 1 "(?<=^WordpressDBUser = ).*$" /root/NeXt-Server/login_information.txt)
WordpressScriptPath=$(grep -Pom 1 "(?<=^WordpressScriptPath = ).*$" /root/NeXt-Server/login_information.txt)


mysql -u root -p${MYSQL_ROOT_PASS} -e "DROP DATABASE IF EXISTS ${WORDPRESS_DB_NAME};"
mysql -u root -p${MYSQL_ROOT_PASS} -e "DROP USER ${WordpressDBUser}@localhost;"
rm -rf /etc/nginx/html/${WordpressScriptPath}
rm -rf /etc/nginx/sites-custom/wordpress.conf


}
