#!/bin/bash

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

cat > /var/vmail/sieve/global/spam-global.sieve <<END
require "fileinto";

if header :contains "X-Spam-Flag" "YES" {
    fileinto "Spam";
}

if header :is "X-Spam" "Yes" {
    fileinto "Spam";
}
END

cat > /var/vmail/sieve/global/learn-spam.sieve <<END
require ["vnd.dovecot.pipe", "copy", "imapsieve"];
pipe :copy "rspamc" ["learn_spam"];
END

cat > /var/vmail/sieve/global/learn-ham.sieve <<END
require ["vnd.dovecot.pipe", "copy", "imapsieve"];
pipe :copy "rspamc" ["learn_ham"];
END
}
