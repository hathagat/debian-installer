#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script! 
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
