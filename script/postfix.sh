#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script! 
#-------------------------------------------------------------------------------------------------------------

install_postfix() {

#smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt in main.cf

DEBIAN_FRONTEND=noninteractive apt-get -y install postfix postfix-mysql >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install postfix packages"

systemctl stop postfix

cd /etc/postfix
rm -r sasl
rm master.cf main.cf.proto master.cf.proto

cp ${SCRIPT_PATH}/configs/postfix/main.cf /etc/postfix/main.cf
sed -i "s/domain.tld/${MYDOMAIN}/g" /etc/postfix/main.cf
IPADR=$(ip route get 9.9.9.9 | awk '/9.9.9.9/ {print $NF}')
sed -i "s/changeme/${IPADR}/g" /etc/postfix/main.cf

cp ${SCRIPT_PATH}/configs/postfix/master.cf /etc/postfix/master.cf
cp ${SCRIPT_PATH}/configs/postfix/submission_header_cleanup /etc/postfix/submission_header_cleanup

mkdir /etc/postfix/sql
cp -R ${SCRIPT_PATH}/configs/postfix/sql/* /etc/postfix/sql/
sed -i "s/placeholder/${MAILSERVER_DB_PASS}/g" /etc/postfix/sql/accounts.cf
sed -i "s/placeholder/${MAILSERVER_DB_PASS}/g" /etc/postfix/sql/aliases.cf
sed -i "s/placeholder/${MAILSERVER_DB_PASS}/g" /etc/postfix/sql/domains.cf
sed -i "s/placeholder/${MAILSERVER_DB_PASS}/g" /etc/postfix/sql/recipient-access.cf
sed -i "s/placeholder/${MAILSERVER_DB_PASS}/g" /etc/postfix/sql/sender-login-maps.cf
sed -i "s/placeholder/${MAILSERVER_DB_PASS}/g" /etc/postfix/sql/tls-policy.cf
chmod -R 640 /etc/postfix/sql

touch /etc/postfix/without_ptr
touch /etc/postfix/postscreen_access

postmap /etc/postfix/without_ptr
newaliases

}
