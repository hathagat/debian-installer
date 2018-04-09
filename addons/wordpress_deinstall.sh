#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
# thx to https://gist.github.com/bgallagh3r
#-------------------------------------------------------------------------------------------------------------

deinstall_wordpress() {
source ${SCRIPT_PATH}/configs/userconfig.cfg
set -x

# --- MYDOMAIN ---
source ${SCRIPT_PATH}/script/functions.sh; get_domain


# Begin Debug
if [ -z "${MYDOMAIN}" ]; then
echo "Domain is Empty!"
# End Debug
exit 1
else
echo "Domain name is: ${MYDOMAIN}"
fi


MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" /root/NeXt-Server/login_information.txt)
WORDPRESS_DB_NAME=$(grep -Pom 1 "(?<=^WordpressDBName = ).*$" /root/NeXt-Server/login_information.txt)
WordpressDBUser=$(grep -Pom 1 "(?<=^WordpressDBUser = ).*$" /root/NeXt-Server/login_information.txt)
WordpressScriptPath=$(grep -Pom 1 "(?<=^WordpressScriptPath = ).*$" /root/NeXt-Server/login_information.txt)


mysql -u root -p${MYSQL_ROOT_PASS} -e "DROP DATABASE IF EXISTS ${WORDPRESS_DB_NAME};"
mysql -u root -p${MYSQL_ROOT_PASS} -e "DROP USER ${WordpressDBUser}@localhost;"

#rm -rf /etc/nginx/html/${WordpressScriptPath}
#deactivated https://github.com/shoujii/NeXt-Server/issues/47
#in root /, only delete single wordpress files - folders to prevent this

# Add here Folder to SAVEFOLDERS
# Put into Function
#SAVEFOLDERS="nextcloud|webmail" # Folder1|Folder2|Folder3|....
#rm -rf /etc/nginx/html/${WordpressScriptPath}/!(${SAVEFOLDERS})

rm -rf /etc/nginx/html/wordpress
rm -rf /etc/nginx/sites-custom/wordpress.conf

sed -i "9d" /etc/nginx/sites-available/${MYDOMAIN}.conf
sed -i "9i           root\t\t\t/etc/nginx/html/${MYDOMAIN};" /etc/nginx/sites-available/${MYDOMAIN}.conf

service nginx restart
#mkdir /etc/nginx/html/${MYDOMAIN}
#cp ${SCRIPT_PATH}/NeXt-logo.jpg /etc/nginx/html/${MYDOMAIN}/
#cp ${SCRIPT_PATH}/configs/nginx/index.html /etc/nginx/html/${MYDOMAIN}/index.html

}
