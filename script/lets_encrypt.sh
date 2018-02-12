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

systemctl -q stop nginx.service
mkdir -p /etc/nginx/ssl/

apt-get -y --assume-yes install cron netcat-openbsd curl socat >>"${main_log}" 2>>"${err_log}"
cd ${SCRIPT_PATH}/sources
git clone https://github.com/Neilpang/acme.sh.git -q >>"${main_log}" 2>>"${err_log}"
cd ./acme.sh
sleep 1
./acme.sh --install >>"${main_log}" 2>>"${err_log}"
# --accountemail  "${SSLMAIL}"

. ~/.bashrc >>"${main_log}" 2>>"${err_log}"
. ~/.profile >>"${main_log}" 2>>"${err_log}"
systemctl -q start nginx.service

}

create_nginx_cert() {

systemctl -q stop nginx.service

cd ${SCRIPT_PATH}/sources/acme.sh/
bash acme.sh --issue --standalone -d ${MYDOMAIN} -d www.${MYDOMAIN} --keylength ec-384 >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to get let's encrypt cert"

ln -s /root/.acme.sh/${MYDOMAIN}_ecc/fullchain.cer /etc/nginx/ssl/${MYDOMAIN}-ecc.cer >>"${main_log}" 2>>"${err_log}"
ln -s /root/.acme.sh/${MYDOMAIN}_ecc/${MYDOMAIN}.key /etc/nginx/ssl/${MYDOMAIN}-ecc.key >>"${main_log}" 2>>"${err_log}"

HPKP1=$(openssl x509 -pubkey < /etc/nginx/ssl/${MYDOMAIN}-ecc.cer | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64) >>"${main_log}" 2>>"${err_log}"
HPKP2=$(openssl rand -base64 32) >>"${main_log}" 2>>"${err_log}"

systemctl -q start nginx.service

}

update_lets_encrypt() {
  cd ${SCRIPT_PATH}/.acme.sh/
  acme.sh --upgrade
}

renew_lets_encrypt_certs() {

cd ${SCRIPT_PATH}/.acme.sh/
bash acme.sh --renew -d ${MYDOMAIN} -d www.${MYDOMAIN} --force --ecc >>"${main_log}" 2>>"${err_log}"

}
