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

install_dovecot() {

DEBIAN_FRONTEND=noninteractive apt-get -y install dovecot-core dovecot-imapd dovecot-lmtpd dovecot-mysql dovecot-sieve dovecot-managesieved >>"${main_log}" 2>>"${err_log}"

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
