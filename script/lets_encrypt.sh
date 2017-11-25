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

#################################
##  DO NOT MODIFY, JUST DON'T! ##
#################################

install_lets_encrypt() {

echo "50" | dialog --gauge "Creating SSL CERT - This can take a long time! ..." 10 70 0
# SSL certificate
service nginx stop
if [[ ${CLOUDFLARE} == '0' ]] && [[ ${USE_VALID_SSL} == '1' ]]; then

	mkdir -p /etc/nginx/ssl/

	apt-get -y --assume-yes install cron netcat-openbsd curl socat >>"$main_log" 2>>"$err_log" || error_exit "Failed to install cron netcat-openbsd curl socat! Aborting"
	cd ~/sources
	git clone https://github.com/Neilpang/acme.sh.git -q >>"$main_log" 2>>"$err_log" || error_exit "Failed to download acme! Aborting"
	cd ./acme.sh
	sleep 1
	./acme.sh --install --accountemail  "${SSLMAIL}" >>"$main_log" 2>>"$err_log"
	
	. ~/.bashrc >>"$main_log" 2>>"$err_log"
	. ~/.profile >>"$main_log" 2>>"$err_log"
	cd /root/.acme.sh/

	if [[ ${USE_MAILSERVER} == '1' ]] && [[ ${USE_ECC} == '1' ]]; then
		bash acme.sh --issue --standalone -d ${MYDOMAIN} -d www.${MYDOMAIN} -d mail.${MYDOMAIN} --keylength ec-384 >>"$main_log" 2>>"$err_log"
	else
		bash acme.sh --issue --standalone -d ${MYDOMAIN} -d www.${MYDOMAIN} --keylength ec-384 >>"$main_log" 2>>"$err_log"
	fi	
	
	if [[ ${USE_MAILSERVER} == '1' ]] && [[ ${USE_RSA} == '1' ]]; then
		bash acme.sh --issue --standalone -d ${MYDOMAIN} -d www.${MYDOMAIN} -d mail.${MYDOMAIN} --keylength ${RSA_KEY_SIZE} >>"$main_log" 2>>"$err_log"
	else
		bash acme.sh --issue --standalone -d ${MYDOMAIN} -d www.${MYDOMAIN} --keylength ${RSA_KEY_SIZE} >>"$main_log" 2>>"$err_log"
	fi	
	
	if [[ ${USE_ECC} == '1' ]]; then
		ln -s /root/.acme.sh/${MYDOMAIN}_ecc/fullchain.cer /etc/nginx/ssl/${MYDOMAIN}-ecc.cer >>"$main_log" 2>>"$err_log" || error_exit "Failed to ln -s /root/.acme.sh/${MYDOMAIN}_ecc/fullchain.cer /etc/nginx/ssl/${MYDOMAIN}.cer! Aborting"
		ln -s /root/.acme.sh/${MYDOMAIN}_ecc/${MYDOMAIN}.key /etc/nginx/ssl/${MYDOMAIN}-ecc.key >>"$main_log" 2>>"$err_log" || error_exit "Failed to ln -s /root/.acme.sh/${MYDOMAIN}_ecc/${MYDOMAIN}.key /etc/nginx/ssl/${MYDOMAIN}.key! Aborting"	
		SSL_CERT_ECC="ssl_certificate 	ssl/${MYDOMAIN}-ecc.cer;"
		SSL_KEY_ECC="ssl_certificate_key 	ssl/${MYDOMAIN}-ecc.key;"
	fi
	
	if [[ ${USE_RSA} == '1' ]]; then
		ln -s /root/.acme.sh/${MYDOMAIN}/fullchain.cer /etc/nginx/ssl/${MYDOMAIN}.cer >>"$main_log" 2>>"$err_log" || error_exit "Failed to ln -s /root/.acme.sh/${MYDOMAIN}_ecc/fullchain.cer /etc/nginx/ssl/${MYDOMAIN}.cer! Aborting"
		ln -s /root/.acme.sh/${MYDOMAIN}/${MYDOMAIN}.key /etc/nginx/ssl/${MYDOMAIN}.key >>"$main_log" 2>>"$err_log" || error_exit "Failed to ln -s /root/.acme.sh/${MYDOMAIN}_ecc/${MYDOMAIN}.key /etc/nginx/ssl/${MYDOMAIN}.key! Aborting"	
		SSL_CERT_RSA="ssl_certificate 	ssl/${MYDOMAIN}.cer;"
		SSL_KEY_RSA="ssl_certificate_key 	ssl/${MYDOMAIN}.key;"
	fi
	
	#Your cert is in  /root/.acme.sh/${MYDOMAIN}_ecc/${MYDOMAIN}.cer
	#Your cert key is in  /root/.acme.sh/${MYDOMAIN}_ecc/${MYDOMAIN}.key
	#The intermediate CA cert is in  /root/.acme.sh/${MYDOMAIN}_ecc/ca.cer
	#And the full chain certs is there:  /root/.acme.sh/${MYDOMAIN}_ecc/fullchain.cer		
fi

if [[ ${USE_ECC} == '1' ]]; then
	HPKP1=$(openssl x509 -pubkey < /etc/nginx/ssl/${MYDOMAIN}-ecc.cer | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64) >>"$main_log" 2>>"$err_log" || error_exit "Failed to HPKP1=$(openssl x509 -pubkey < /etc/nginx/ssl/${MYDOMAIN}-ecc.cer | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64)! Aborting"
	HPKP2=$(openssl rand -base64 32) >>"$main_log" 2>>"$err_log" || error_exit "Failed to HPKP2=$(openssl rand -base64 32)! Aborting"
fi

if [[ ${USE_RSA} == '1' ]]; then
	HPKP1=$(openssl x509 -pubkey < /etc/nginx/ssl/${MYDOMAIN}.cer | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64) >>"$main_log" 2>>"$err_log" || error_exit "Failed to HPKP1=$(openssl x509 -pubkey < /etc/nginx/ssl/${MYDOMAIN}.cer | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64)! Aborting"
	HPKP2=$(openssl rand -base64 32) >>"$main_log" 2>>"$err_log" || error_exit "Failed to HPKP2=$(openssl rand -base64 32)! Aborting"
fi

openssl dhparam -out /etc/nginx/ssl/dh.pem ${RSA_KEY_SIZE} >>"$main_log" 2>>"$err_log" || error_exit "Failed to openssl dhparam -out /etc/nginx/ssl/dh.pem ${RSA_KEY_SIZE}! Aborting"
}