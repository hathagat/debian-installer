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

install_lets_encrypt() {

set -x

echo "50" | dialog --gauge "Creating SSL CERT - This can take a long time! ..." 10 70 0
# SSL certificate
service nginx stop
mkdir -p /etc/nginx/ssl/

apt-get -y --assume-yes install cron netcat-openbsd curl socat >>"${main_log}" 2>>"${err_log}"
cd ~/sources
git clone https://github.com/Neilpang/acme.sh.git -q >>"${main_log}" 2>>"${err_log}"
cd ./acme.sh
sleep 1
./acme.sh --install --accountemail  "${SSLMAIL}" >>"${main_log}" 2>>"${err_log}"

. ~/.bashrc >>"${main_log}" 2>>"${err_log}"
. ~/.profile >>"${main_log}" 2>>"${err_log}"
cd /root/.acme.sh/

#if [[ ${USE_MAILSERVER} == '1' ]]; then
#	bash acme.sh --issue --standalone -d ${MYDOMAIN} -d www.${MYDOMAIN} -d mail.${MYDOMAIN} --keylength ec-384 >>"${main_log}" 2>>"${err_log}"
#else
#	bash acme.sh --issue --standalone -d ${MYDOMAIN} -d www.${MYDOMAIN} --keylength ec-384 >>"${main_log}" 2>>"${err_log}"
#fi

openssl ecparam -genkey -name secp384r1 -out /etc/nginx/ssl/${MYDOMAIN}.key.pem >>"$main_log" 2>>"$err_log"
openssl req -new -sha256 -key /etc/nginx/ssl/${MYDOMAIN}.key.pem -out /etc/nginx/ssl/csr.pem -subj "/C=DE/ST=Private/L=Private/O=Private/OU=Private/CN=*.${MYDOMAIN}" >>"$main_log" 2>>"$err_log"
openssl req -x509 -days 365 -key /etc/nginx/ssl/${MYDOMAIN}.key.pem -in /etc/nginx/ssl/csr.pem -out /etc/nginx/ssl/${MYDOMAIN}.pem >>"$main_log" 2>>"$err_log"
HPKP1=$(openssl x509 -pubkey < /etc/nginx/ssl/${MYDOMAIN}.pem | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64)
HPKP2=$(openssl rand -base64 32)


#ln -s /root/.acme.sh/${MYDOMAIN}_ecc/fullchain.cer /etc/nginx/ssl/${MYDOMAIN}-ecc.cer >>"${main_log}" 2>>"${err_log}"
#ln -s /root/.acme.sh/${MYDOMAIN}_ecc/${MYDOMAIN}.key /etc/nginx/ssl/${MYDOMAIN}-ecc.key >>"${main_log}" 2>>"${err_log}"

#Your cert is in  /root/.acme.sh/${MYDOMAIN}_ecc/${MYDOMAIN}.cer
#Your cert key is in  /root/.acme.sh/${MYDOMAIN}_ecc/${MYDOMAIN}.key
#The intermediate CA cert is in  /root/.acme.sh/${MYDOMAIN}_ecc/ca.cer
#And the full chain certs is there:  /root/.acme.sh/${MYDOMAIN}_ecc/fullchain.cer

#HPKP1=$(openssl x509 -pubkey < /etc/nginx/ssl/${MYDOMAIN}-ecc.cer | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64) >>"${main_log}" 2>>"${err_log}"
#HPKP2=$(openssl rand -base64 32) >>"${main_log}" 2>>"${err_log}"

openssl dhparam -out /etc/nginx/ssl/dh.pem 4096 >>"${main_log}" 2>>"${err_log}"
}
