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

rm -r /etc/dovecot/*
cd /etc/dovecot

cat > /etc/dovecot/dovecot.conf <<END
###
### Aktivierte Protokolle
#############################

protocols = imap lmtp sieve



###
### TLS Config
#######################

ssl = required
ssl_cert = /etc/nginx/ssl/domain.tld-ecc.cer
ssl_key = /etc/nginx/ssl/domain.tld-ecc.key;
ssl_dh_parameters_length = 2048
ssl_protocols = !SSLv3
ssl_cipher_list = EDH+CAMELLIA:EDH+aRSA:EECDH+aRSA+AESGCM:EECDH+aRSA+SHA256:EECDH:+CAMELLIA128:+AES128:+SSLv3:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!IDEA:!ECDSA:kEDH:CAMELLIA128-SHA:AES128-SHA
ssl_prefer_server_ciphers = yes



###
### Dovecot services
################################

service imap-login {
    inet_listener imap {
        port = 143
    }
}


service managesieve-login {
    inet_listener sieve {
        port = 4190
    }
}


service lmtp {
    unix_listener /var/spool/postfix/private/dovecot-lmtp {
        mode = 0660
        group = postfix
        user = postfix
    }

    user = vmail
}


service auth {
    ### Auth socket für Postfix
    unix_listener /var/spool/postfix/private/auth {
        mode = 0660
        user = postfix
        group = postfix
    }

    ### Auth socket für LMTP-Dienst
    unix_listener auth-userdb {
        mode = 0660
        user = vmail
        group = vmail
    }
}


###
###  Protocol settings
#############################

protocol imap {
    mail_plugins = $mail_plugins quota imap_quota imap_sieve
    mail_max_userip_connections = 20
    imap_idle_notify_interval = 29 mins
}

protocol lmtp {
    postmaster_address = domain.tld
    mail_plugins = $mail_plugins sieve
}



###
### Client authentication
#############################

disable_plaintext_auth = yes
auth_mechanisms = plain login


passdb {
    driver = sql
    args = /etc/dovecot/dovecot-sql.conf
}

userdb {
    driver = sql
    args = /etc/dovecot/dovecot-sql.conf
}


###
### Mail location
#######################

mail_uid = vmail
mail_gid = vmail
mail_privileged_group = vmail


mail_home = /var/vmail/mailboxes/%d/%n
mail_location = maildir:~/mail:LAYOUT=fs



###
### Mailbox configuration
########################################

namespace inbox {
    inbox = yes

    mailbox Spam {
        auto = subscribe
        special_use = \Junk
    }

    mailbox Trash {
        auto = subscribe
        special_use = \Trash
    }

    mailbox Drafts {
        auto = subscribe
        special_use = \Drafts
    }

    mailbox Sent {
        auto = subscribe
        special_use = \Sent
    }
}



###
### Mail plugins
############################


plugin {
    sieve_plugins = sieve_imapsieve sieve_extprograms
    sieve_before = /var/vmail/sieve/global/spam-global.sieve
    sieve = file:/var/vmail/sieve/%d/%n/scripts;active=/var/vmail/sieve/%d/%n/active-script.sieve

    ###
    ### Spam learning
    ###
    # From elsewhere to Spam folder
    imapsieve_mailbox1_name = Spam
    imapsieve_mailbox1_causes = COPY
    imapsieve_mailbox1_before = file:/var/vmail/sieve/global/learn-spam.sieve

    # From Spam folder to elsewhere
    imapsieve_mailbox2_name = *
    imapsieve_mailbox2_from = Spam
    imapsieve_mailbox2_causes = COPY
    imapsieve_mailbox2_before = file:/var/vmail/sieve/global/learn-ham.sieve

    sieve_pipe_bin_dir = /usr/bin
    sieve_global_extensions = +vnd.dovecot.pipe

    quota = maildir:User quota
    quota_exceeded_message = Benutzer %u hat das Speichervolumen überschritten. / User %u has exhausted allowed storage space.
}
END

sed -i "s/domain.tld/${MYDOMAIN}/g" /etc/dovecot/dovecot.conf

cat > /etc/dovecot/dovecot-sql.conf <<END
driver=mysql
connect = "host=127.0.0.1 dbname=vmail user=vmail password=vmaildbpass"
default_pass_scheme = SHA512-CRYPT

password_query = SELECT username AS user, domain, password FROM accounts WHERE username = '%n' AND domain = '%d' and enabled = true;
user_query = SELECT concat('*:storage=', quota, 'M') AS quota_rule FROM accounts WHERE username = '%n' AND domain = '%d' AND sendonly = false;
iterate_query = SELECT username, domain FROM accounts where sendonly = false;
END

chmod 440 /etc/dovecot/dovecot-sql.conf

### change vmaildbpass

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
