#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_rspamd() {

DEBIAN_FRONTEND=noninteractive apt-get -y install lsb-release wget >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install lsb-release wget packages"

wget -q -O- https://rspamd.com/apt-stable/gpg.key | apt-key add - >>"${main_log}" 2>>"${err_log}"
echo "deb http://rspamd.com/apt-stable/ $(lsb_release -c -s) main" > /etc/apt/sources.list.d/rspamd.list
echo "deb-src http://rspamd.com/apt-stable/ $(lsb_release -c -s) main" >> /etc/apt/sources.list.d/rspamd.list

apt-get update -y >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get -y install rspamd >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install rspamd package"
systemctl stop rspamd

cp ${SCRIPT_PATH}/configs/rspamd/options.inc /etc/rspamd/local.d/options.inc
cp ${SCRIPT_PATH}/configs/rspamd/worker-normal.inc /etc/rspamd/local.d/worker-normal.inc
cp ${SCRIPT_PATH}/configs/rspamd/classifier-bayes.conf /etc/rspamd/local.d/classifier-bayes.conf

RSPAMADM_PASSWORT=$(password)

if [[ -z ${!RSPAMADM_PASSWORT} ]]; then
  RSPAMADM_PASSWORT=$(password)
fi

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "RSPAMADM URL: https://${MYDOMAIN}/rspamd/" >> ${SCRIPT_PATH}/login_information.txt
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "RSPAMADM_PASSWORT: $RSPAMADM_PASSWORT" >> ${SCRIPT_PATH}/login_information.txt
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt

RSPAMADM_PASSWORT_HASH=$(rspamadm pw -p ${RSPAMADM_PASSWORT})

cat > /etc/rspamd/local.d/worker-controller.inc <<END
password = "${RSPAMADM_PASSWORT_HASH}";
END

cp ${SCRIPT_PATH}/configs/rspamd/worker-proxy.inc /etc/rspamd/local.d/worker-proxy.inc
cp ${SCRIPT_PATH}/configs/rspamd/logging.inc /etc/rspamd/local.d/logging.inc
cp ${SCRIPT_PATH}/configs/rspamd/milter_headers.conf /etc/rspamd/local.d/milter_headers.conf

CURRENT_YEAR=$(date +'%Y')

mkdir /var/lib/rspamd/dkim/
rspamadm dkim_keygen -b 2048 -s ${CURRENT_YEAR} -k /var/lib/rspamd/dkim/${CURRENT_YEAR}.key > /var/lib/rspamd/dkim/${CURRENT_YEAR}.txt
chown -R _rspamd:_rspamd /var/lib/rspamd/dkim
chmod 440 /var/lib/rspamd/dkim/*
cat /var/lib/rspamd/dkim/${CURRENT_YEAR}.txt
cp /var/lib/rspamd/dkim/${CURRENT_YEAR}.txt ${SCRIPT_PATH}/DKIM_KEY_ADD_TO_DNS.txt

cp ${SCRIPT_PATH}/configs/rspamd/dkim_signing.conf /etc/rspamd/local.d/dkim_signing.conf
sed -i "s/placeholder/${CURRENT_YEAR}/g" /etc/rspamd/local.d/dkim_signing.conf

cp -R /etc/rspamd/local.d/dkim_signing.conf /etc/rspamd/local.d/arc.conf

DEBIAN_FRONTEND=noninteractive apt-get -y install redis-server >>"${main_log}" 2>>"${err_log}"
cp ${SCRIPT_PATH}/configs/rspamd/redis.conf /etc/rspamd/local.d/redis.conf

mkdir -p /etc/nginx/sites-custom

cat >> /etc/nginx/sites-custom/rspamd.conf << 'EOF1'
location /rspamd/ {
  proxy_pass http://localhost:11334/;
	proxy_set_header Host $host;
	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
EOF1

systemctl restart nginx
systemctl start rspamd
systemctl start dovecot
systemctl start postfix

}
