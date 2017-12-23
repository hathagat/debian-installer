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

cat > /etc/postfix/main.cf <<END
##
## Netzwerkeinstellungen
##

mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128
inet_interfaces = 127.0.0.1, ::1, 5.1.76.152, 2a00:f820:417::7647:b2c2
myhostname = mail.mysystems.tld


##
## Mail-Queue Einstellungen
##

maximal_queue_lifetime = 1h
bounce_queue_lifetime = 1h
maximal_backoff_time = 15m
minimal_backoff_time = 5m
queue_run_delay = 5m


##
## TLS Einstellungen
###

tls_ssl_options = NO_COMPRESSION
tls_high_cipherlist = EDH+CAMELLIA:EDH+aRSA:EECDH+aRSA+AESGCM:EECDH+aRSA+SHA256:EECDH:+CAMELLIA128:+AES128:+SSLv3:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!IDEA:!ECDSA:kEDH:CAMELLIA128-SHA:AES128-SHA

### Ausgehende SMTP-Verbindungen (Postfix als Sender)

smtp_tls_security_level = dane
smtp_dns_support_level = dnssec
smtp_tls_policy_maps = mysql:/etc/postfix/sql/tls-policy.cf
smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache
smtp_tls_protocols = !SSLv2, !SSLv3
smtp_tls_ciphers = high
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt


### Eingehende SMTP-Verbindungen

smtpd_tls_security_level = may
smtpd_tls_protocols = !SSLv2, !SSLv3
smtpd_tls_ciphers = high
smtpd_tls_session_cache_database = btree:${data_directory}/smtpd_scache

smtpd_tls_cert_file=/etc/letsencrypt/live/mail.mysystems.tld/fullchain.pem
smtpd_tls_key_file=/etc/letsencrypt/live/mail.mysystems.tld/privkey.pem


##
## Lokale Mailzustellung an Dovecot
##

virtual_transport = lmtp:unix:private/dovecot-lmtp


##
## Spamfilter und DKIM-Signaturen via Rspamd
##

smtpd_milters = inet:localhost:11332
non_smtpd_milters = inet:localhost:11332
milter_protocol = 6
milter_mail_macros =  i {mail_addr} {client_addr} {client_name} {auth_authen}
milter_default_action = accept



##
## Server Restrictions für Clients, Empfänger und Relaying
## (im Bezug auf S2S-Verbindungen. Mailclient-Verbindungen werden in master.cf im Submission-Bereich konfiguriert)
##

### Bedingungen, damit Postfix als Relay arbeitet (für Clients)
smtpd_relay_restrictions =      reject_non_fqdn_recipient
                                reject_unknown_recipient_domain
                                permit_mynetworks
                                reject_unauth_destination


### Bedingungen, damit Postfix ankommende E-Mails als Empfängerserver entgegennimmt (zusätzlich zu relay-Bedingungen)
### check_recipient_access prüft, ob ein account sendonly ist
smtpd_recipient_restrictions = check_recipient_access mysql:/etc/postfix/sql/recipient-access.cf


### Bedingungen, die SMTP-Clients erfüllen müssen (sendende Server)
smtpd_client_restrictions =     permit_mynetworks
                                check_client_access hash:/etc/postfix/without_ptr
                                reject_unknown_client_hostname


### Wenn fremde Server eine Verbindung herstellen, müssen sie einen gültigen Hostnamen im HELO haben.
smtpd_helo_required = yes
smtpd_helo_restrictions =   permit_mynetworks
                            reject_invalid_helo_hostname
                            reject_non_fqdn_helo_hostname
                            reject_unknown_helo_hostname

# Clients blockieren, wenn sie versuchen zu früh zu senden
smtpd_data_restrictions = reject_unauth_pipelining


##
## Restrictions für MUAs (Mail user agents)
##

mua_relay_restrictions = reject_non_fqdn_recipient,reject_unknown_recipient_domain,permit_mynetworks,permit_sasl_authenticated,reject
mua_sender_restrictions = permit_mynetworks,reject_non_fqdn_sender,reject_sender_login_mismatch,permit_sasl_authenticated,reject
mua_client_restrictions = permit_mynetworks,permit_sasl_authenticated,reject


##
## Postscreen Filter
##

### Postscreen Whitelist / Blocklist
postscreen_access_list =        permit_mynetworks
                                cidr:/etc/postfix/postscreen_access
postscreen_blacklist_action = drop


# Verbindungen beenden, wenn der fremde Server es zu eilig hat
postscreen_greet_action = drop


### DNS blocklists
postscreen_dnsbl_threshold = 2
postscreen_dnsbl_sites =    ix.dnsbl.manitu.net*2
                            zen.spamhaus.org*2
postscreen_dnsbl_action = drop


##
## MySQL Abfragen
##

virtual_alias_maps = mysql:/etc/postfix/sql/aliases.cf
virtual_mailbox_maps = mysql:/etc/postfix/sql/accounts.cf
virtual_mailbox_domains = mysql:/etc/postfix/sql/domains.cf
local_recipient_maps = $virtual_mailbox_maps


##
## Sonstiges
##

### Maximale Größe der gesamten Mailbox (soll von Dovecot festgelegt werden, 0 = unbegrenzt)
mailbox_size_limit = 0

### Maximale Größe eingehender E-Mails in Bytes (50 MB)
message_size_limit = 52428800

### Keine System-Benachrichtigung für Benutzer bei neuer E-Mail
biff = no

### Nutzer müssen immer volle E-Mail Adresse angeben - nicht nur Hostname
append_dot_mydomain = no

### Trenn-Zeichen für "Address Tagging"
recipient_delimiter = +
END

#ändern inet_interfaces:  myhostname  smtpd_tls_cert_file smtpd_tls_key_file

cat > /etc/postfix/master.cf <<END
# ==========================================================================
# service type  private unpriv  chroot  wakeup  maxproc command + args
#               (yes)   (yes)   (no)    (never) (100)
# ==========================================================================

###
### Postscreen-Service: Prüft eingehende SMTP-Verbindungen auf Spam-Server
###
smtp      inet  n       -       y       -       1       postscreen
    -o smtpd_sasl_auth_enable=no
###
### SMTP-Daemon hinter Postscreen.
###
smtpd     pass  -       -       y       -       -       smtpd
###
### dnsblog führt DNS-Abfragen für Blocklists durch
###
dnsblog   unix  -       -       y       -       0       dnsblog
###
### tlsproxy gibt Postscreen TLS support
###
tlsproxy  unix  -       -       y       -       0       tlsproxy
###
### Submission-Zugang für Clients: Für Mailclients gelten andere Regeln, als für andere Mailserver (siehe smtpd_ in main.cf)
###
submission inet n       -       y       -       -       smtpd
    -o syslog_name=postfix/submission
    -o smtpd_tls_security_level=encrypt
    -o smtpd_sasl_auth_enable=yes
    -o smtpd_sasl_type=dovecot
    -o smtpd_sasl_path=private/auth
    -o smtpd_sasl_security_options=noanonymous
    -o smtpd_client_restrictions=$mua_client_restrictions
    -o smtpd_sender_restrictions=$mua_sender_restrictions
    -o smtpd_relay_restrictions=$mua_relay_restrictions
    -o milter_macro_daemon_name=ORIGINATING
    -o smtpd_sender_login_maps=mysql:/etc/postfix/sql/sender-login-maps.cf
    -o smtpd_helo_required=no
    -o smtpd_helo_restrictions=
    -o cleanup_service_name=submission-header-cleanup
###
### Weitere wichtige Dienste für den Serverbetrieb
###
pickup    unix  n       -       y       60      1       pickup
cleanup   unix  n       -       y       -       0       cleanup
qmgr      unix  n       -       n       300     1       qmgr
tlsmgr    unix  -       -       y       1000?   1       tlsmgr
rewrite   unix  -       -       y       -       -       trivial-rewrite
bounce    unix  -       -       y       -       0       bounce
defer     unix  -       -       y       -       0       bounce
trace     unix  -       -       y       -       0       bounce
verify    unix  -       -       y       -       1       verify
flush     unix  n       -       y       1000?   0       flush
proxymap  unix  -       -       n       -       -       proxymap
proxywrite unix -       -       n       -       1       proxymap
smtp      unix  -       -       y       -       -       smtp
relay     unix  -       -       y       -       -       smtp
showq     unix  n       -       y       -       -       showq
error     unix  -       -       y       -       -       error
retry     unix  -       -       y       -       -       error
discard   unix  -       -       y       -       -       discard
local     unix  -       n       n       -       -       local
virtual   unix  -       n       n       -       -       virtual
lmtp      unix  -       -       y       -       -       lmtp
anvil     unix  -       -       y       -       1       anvil
scache    unix  -       -       y       -       1       scache
###
### Cleanup-Service um MUA header zu entfernen
###
submission-header-cleanup unix n - n    -       0       cleanup
    -o header_checks=regexp:/etc/postfix/submission_header_cleanup
END

cat > /etc/postfix/submission_header_cleanup <<END
### Entfernt Datenschutz-relevante Header aus E-Mails von MTUAs

/^Received:/            IGNORE
/^X-Originating-IP:/    IGNORE
/^X-Mailer:/            IGNORE
/^User-Agent:/          IGNORE
END

mkdir /etc/postfix/sql && cd /etc/postfix/sql/

cat > /etc/postfix/sql/accounts.cf <<END
user = vmail
password = vmaildbpass
hosts = 127.0.0.1
dbname = vmail
query = select 1 as found from accounts where username = '%u' and domain = '%d' and enabled = true LIMIT 1;
END

cat > /etc/postfix/sql/aliases.cf <<END
user = vmail
password = vmaildbpass
hosts = 127.0.0.1
dbname = vmail
query = select concat(destination_username, '@', destination_domain) as destinations from aliases where source_username = '%u' and source_domain = '%d' and enabled = true;
END

cat > /etc/postfix/sql/domains.cf <<END
user = vmail
password = vmaildbpass
hosts = 127.0.0.1
dbname = vmail
query = SELECT domain FROM domains WHERE domain='%s'
END

cat > /etc/postfix/sql/recipient-access.cf <<END
user = vmail
password = vmaildbpass
hosts = 127.0.0.1
dbname = vmail
query = select if(sendonly = true, 'REJECT', 'OK') AS access from accounts where username = '%u' and domain = '%d' and enabled = true LIMIT 1;
END

cat > /etc/postfix/sql/sender-login-maps.cf <<END
user = vmail
password = vmaildbpass
hosts = 127.0.0.1
dbname = vmail
query = select concat(username, '@', domain) as 'owns' from accounts where username = '%u' AND domain = '%d' and enabled = true union select concat(destination_username, '@', destination_domain) AS 'owns' from aliases where source_username = '%u' and source_domain = '%d' and enabled = true;
END


cat > /etc/postfix/sql/tls-policy.cf <<END
user = vmail
password = vmaildbpass
hosts = 127.0.0.1
dbname = vmail
query = SELECT policy, params FROM tlspolicies WHERE domain = '%s'
END

chmod -R 640 /etc/postfix/sql

touch /etc/postfix/without_ptr
touch /etc/postfix/postscreen_access

postmap /etc/postfix/without_ptr

newaliases


}