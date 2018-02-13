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


install_mailserver() {

systemctl -q stop nginx.service

SCRIPT_PATH="/root/NeXt-Server"

cd ${SCRIPT_PATH}/sources/acme.sh/
bash acme.sh --issue --standalone -d mail.${MYDOMAIN} -d imap.${MYDOMAIN} -d smtp.${MYDOMAIN} --keylength 4096 >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to get mailserver let's encrypt cert"
ln -s /root/.acme.sh/mail.${MYDOMAIN}/fullchain.cer /etc/nginx/ssl/mail.${MYDOMAIN}.cer
ln -s /root/.acme.sh/mail.${MYDOMAIN}/mail.${MYDOMAIN}.key /etc/nginx/ssl/mail.${MYDOMAIN}.key

systemctl -q start nginx.service

MAILSERVER_DB_PASS=$(password)

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "MAILSERVER_DB_PASS: $MAILSERVER_DB_PASS" >> ${SCRIPT_PATH}/login_information
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information

sed -i "s/placeholder/${MAILSERVER_DB_PASS}/g" ${SCRIPT_PATH}/configs/mailserver/database.sql
mysql -u root -p${MYSQL_ROOT_PASS} mysql < ${SCRIPT_PATH}/configs/mailserver/database.sql

adduser --gecos "" --disabled-login --disabled-password --home /var/vmail vmail >>"${main_log}" 2>>"${err_log}"

mkdir -p /var/vmail/mailboxes
mkdir -p /var/vmail/sieve/global
chown -R vmail /var/vmail
chgrp -R vmail /var/vmail
chmod -R 770 /var/vmail

}
