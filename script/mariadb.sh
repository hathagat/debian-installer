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

DEBIAN_FRONTEND=noninteractive apt-get -y install mariadb-server >>"${main_log}" 2>>"${err_log}"

MYSQL_ROOT_PASS=$(password)
echo  "MYSQL_ROOT_PASS password: $MYSQL_ROOT_PASS" >> ${SCRIPT_PATH}/login_information

mysqladmin -u root password ${MYSQL_ROOT_PASS}

sed -i 's/.*max_allowed_packet.*/max_allowed_packet = 128M/g' /etc/mysql/my.cnf
sed -i '32s/.*/innodb_file_per_table = 1\n&/' /etc/mysql/my.cnf
sed -i '33s/.*/innodb_additional_mem_pool_size = 50M\n&/' /etc/mysql/my.cnf
sed -i '34s/.*/innodb_thread_concurrency = 4\n&/' /etc/mysql/my.cnf
sed -i '35s/.*/innodb_flush_method = O_DSYNC\n&/' /etc/mysql/my.cnf
sed -i '36s/.*/innodb_flush_log_at_trx_commit = 0\n&/' /etc/mysql/my.cnf
sed -i '37s/.*/#innodb_buffer_pool_size = 2G #reserved RAM, reduce i\/o\n&/' /etc/mysql/my.cnf
sed -i '38s/.*/innodb_log_files_in_group = 2\n&/' /etc/mysql/my.cnf
sed -i '39s/.*/innodb_log_file_size = 32M\n&/' /etc/mysql/my.cnf
sed -i '40s/.*/innodb_log_buffer_size = 16M\n&/' /etc/mysql/my.cnf
sed -i '41s/.*/#innodb_table_locks = 0 #disable table lock, uncomment if you do not want to crash all applications, if one does\n&/' /etc/mysql/my.cnf

# Automated mysql_secure_installation
mysql -u root -p${MYSQL_ROOT_PASS} -e "DELETE FROM mysql.user WHERE User=''; DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'); DROP DATABASE IF EXISTS test; FLUSH PRIVILEGES; DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'; FLUSH PRIVILEGES;" >>"${main_log}" 2>>"${err_log}"
}
