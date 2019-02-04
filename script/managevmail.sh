#!/bin/bash
# Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------


install_managevmail() {

trap error_exit ERR

install_packages "python3 python3-mysql.connector"

mkdir -p /etc/managevmail/
wget https://codeload.github.com/mhthies/managevmail/zip/master
unzip master -d /etc/managevmail/
mv /etc/managevmail/managevmail-master/* /etc/managevmail/
rm -R /etc/managevmail/managevmail-master

MAILSERVER_MANAGEVMAIL_PASS=$(password)

mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE USER managevmail@localhost IDENTIFIED BY '${MAILSERVER_MANAGEVMAIL_PASS}';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "GRANT SELECT, UPDATE, INSERT, DELETE ON vmail.* TO managevmail@localhost;"

sed -i "s/?/${MAILSERVER_MANAGEVMAIL_PASS}/g" /etc/managevmail/config.ini

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "MAILSERVER_MANAGEVMAIL_PASS: $MAILSERVER_MANAGEVMAIL_PASS" >> ${SCRIPT_PATH}/login_information.txt
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt
}
