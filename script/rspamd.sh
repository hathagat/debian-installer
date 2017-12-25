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

install_rspamd() {

DEBIAN_FRONTEND=noninteractive apt-get -y install lsb-release wget >>"${main_log}" 2>>"${err_log}"

wget -O- https://rspamd.com/apt-stable/gpg.key | apt-key add -
echo "deb http://rspamd.com/apt-stable/ $(lsb_release -c -s) main" > /etc/apt/sources.list.d/rspamd.list
echo "deb-src http://rspamd.com/apt-stable/ $(lsb_release -c -s) main" >> /etc/apt/sources.list.d/rspamd.list

apt-get update -y >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get -y install rspamd >>"${main_log}" 2>>"${err_log}"
systemctl stop rspamd

cp ${SCRIPT_PATH}/configs/rspamd/options.inc /etc/rspamd/local.d/options.inc
cp ${SCRIPT_PATH}/configs/rspamd/worker-normal.inc /etc/rspamd/local.d/worker-normal.inc
###hier anpassungen mit make compile anzahl

RSPAMADM_PASSWORT=$(password)
echo  "RSPAMADM_PASSWORT password: $RSPAMADM_PASSWORT" >> ${SCRIPT_PATH}/login_information
RSPAMADM_PASSWORT_HASH=$(rspamadm pw -p ${RSPAMADM_PASSWORT})

cat > /etc/rspamd/local.d/worker-controller.inc <<END
password = "${RSPAMADM_PASSWORT_HASH}";
END

cp ${SCRIPT_PATH}/configs/rspamd/worker-proxy.inc /etc/rspamd/local.d/worker-proxy.inc
cp ${SCRIPT_PATH}/configs/rspamd/logging.inc /etc/rspamd/local.d/logging.inc
cp ${SCRIPT_PATH}/configs/rspamd/milter_headers.conf /etc/rspamd/local.d/milter_headers.conf

mkdir /var/lib/rspamd/dkim/
rspamadm dkim_keygen -b 2048 -s 2017 -k /var/lib/rspamd/dkim/2017.key > /var/lib/rspamd/dkim/2017.txt
chown -R _rspamd:_rspamd /var/lib/rspamd/dkim
chmod 440 /var/lib/rspamd/dkim/*
##key jahr ändern 2017 -> 2018
cat /var/lib/rspamd/dkim/2017.txt
##key in dns record packen

cp ${SCRIPT_PATH}/configs/rspamd/dkim_signing.conf /etc/rspamd/local.d/dkim_signing.conf
##key jahr ändern 2017 -> 2018

cp -R /etc/rspamd/local.d/dkim_signing.conf /etc/rspamd/local.d/arc.conf

DEBIAN_FRONTEND=noninteractive apt-get -y install redis-server >>"${main_log}" 2>>"${err_log}"
cp ${SCRIPT_PATH}/configs/rspamd/redis.conf /etc/rspamd/local.d/redis.conf

systemctl start rspamd

}
