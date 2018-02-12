#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#
	# This program is free software; you can redistribute it and/or modify
    # it under the terms of the GNU General Public License as published by
    # the Free Software Foundation; either version 2 of the License, or
    # (at your option) any later version.

    # This program is distributed in the hope that it will be useful,
    # but WITHOUT ANY WARRANTY; without even the implied warranty of
    # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    # GNU General Public License for more details.

    # You should have received a copy of the GNU General Public License along
    # with this program; if not, write to the Free Software Foundation, Inc.,
    # 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#-------------------------------------------------------------------------------------------------------------

install_mariadb() {

DEBIAN_FRONTEND=noninteractive apt-get -y install mariadb-server >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install mariadb-server package"

MYSQLUSER="NXTDBUSER"
MYSQLUSERPW=$(password)

mysql -u root -e "CREATE USER '${MYSQLUSER}'@'localhost' IDENTIFIED BY '${MYSQLUSERPW}';GRANT ALL PRIVILEGES ON * . * TO '${MYSQLUSER}'@'localhost';FLUSH PRIVILEGES;"
mysql -u ${MYSQLUSER} -p${MYSQLUSERPW} -e "DELETE FROM mysql.user WHERE User=''; DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'); DROP DATABASE IF EXISTS test; FLUSH PRIVILEGES; DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'; FLUSH PRIVILEGES;" >>"${main_log}" 2>>"${err_log}"

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "${MYSQLUSER}: ${MYSQLUSERPW}" >> ${SCRIPT_PATH}/login_information
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information

sed -i 's/.*max_allowed_packet.*/max_allowed_packet = 128M/g' /etc/mysql/mariadb.conf.d/50-server.cnf
}
