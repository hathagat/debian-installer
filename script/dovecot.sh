#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_dovecot() {

install_packages "dovecot-core dovecot-imapd dovecot-lmtpd dovecot-mysql dovecot-sieve dovecot-managesieved"

systemctl stop dovecot

mkdir -p /etc/dovecot
cd /etc/dovecot

cp ${SCRIPT_PATH}/configs/dovecot/dovecot.conf /etc/dovecot/dovecot.conf
sed -i "s/domain.tld/${MYDOMAIN}/g" /etc/dovecot/dovecot.conf

cp ${SCRIPT_PATH}/configs/dovecot/dovecot-sql.conf /etc/dovecot/dovecot-sql.conf
sed -i "s/placeholder/${MAILSERVER_DB_PASS}/g" /etc/dovecot/dovecot-sql.conf
chmod 440 /etc/dovecot/dovecot-sql.conf

cp ${SCRIPT_PATH}/configs/dovecot/spam-global.sieve /var/vmail/sieve/global/spam-global.sieve
cp ${SCRIPT_PATH}/configs/dovecot/learn-spam.sieve /var/vmail/sieve/global/learn-spam.sieve
cp ${SCRIPT_PATH}/configs/dovecot/learn-ham.sieve /var/vmail/sieve/global/learn-ham.sieve
}
