#!/bin/bash
# Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_mariadb() {

install_packages "software-properties-common dirmngr"
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8 >>"${main_log}" 2>>"${err_log}"
add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://mirror.netcologne.de/mariadb/repo/10.3/debian stretch main' >>"${main_log}" 2>>"${err_log}"
apt-get update -y >/dev/null 2>&1

MYSQL_ROOT_PASS=$(password)

if [ -z "${MYSQL_ROOT_PASS}" ]; then
    echo "MYSQL_ROOT_PASS is unset or set to the empty string, creating new one!"
    MYSQL_ROOT_PASS=$(password)
fi

debconf-set-selections <<< "mariadb-server mysql-server/root_password password ${MYSQL_ROOT_PASS}"
debconf-set-selections <<< "mariadb-server mysql-server/root_password_again password ${MYSQL_ROOT_PASS}"

install_packages "mariadb-server"

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "MYSQL_ROOT_PASS: $MYSQL_ROOT_PASS" >> ${SCRIPT_PATH}/login_information.txt
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt

sed -i 's/.*max_allowed_packet.*/max_allowed_packet      = 128M/g' /etc/mysql/my.cnf
}
