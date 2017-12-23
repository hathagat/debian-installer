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

install_postfix() {

DEBIAN_FRONTEND=noninteractive apt-get -y install postfix postfix-mysql >>"${main_log}" 2>>"${err_log}"

systemctl stop postfix

cd /etc/postfix
rm -r sasl
rm master.cf main.cf.proto master.cf.proto

cp ${SCRIPT_PATH}/configs/postfix/main.cf /etc/postfix/main.cf
#ändern inet_interfaces:  myhostname  smtpd_tls_cert_file smtpd_tls_key_file

cp ${SCRIPT_PATH}/configs/postfix/master.cf /etc/postfix/master.cf

cp ${SCRIPT_PATH}/configs/postfix/submission_header_cleanup /etc/postfix/submission_header_cleanup

mkdir /etc/postfix/sql
#cp recursiv?
cp ${SCRIPT_PATH}/configs/postfix/accounts.cf /etc/postfix/sql/accounts.cf
cp ${SCRIPT_PATH}/configs/postfix/aliases.cf /etc/postfix/sql/aliases.cf
cp ${SCRIPT_PATH}/configs/postfix/domains.cf /etc/postfix/sql/domains.cf
cp ${SCRIPT_PATH}/configs/postfix/recipient-access.cf /etc/postfix/sql/recipient-access.cf
cp ${SCRIPT_PATH}/configs/postfix/sender-login-maps.cf /etc/postfix/sql/sender-login-maps.cf
cp ${SCRIPT_PATH}/configs/postfix/tls-policy.cf /etc/postfix/sql/tls-policy.cf
chmod -R 640 /etc/postfix/sql

touch /etc/postfix/without_ptr
touch /etc/postfix/postscreen_access

postmap /etc/postfix/without_ptr
newaliases

}
