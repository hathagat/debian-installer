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

menu_options_lets_encrypt() {

HEIGHT=30
WIDTH=60
CHOICE_HEIGHT=4
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

	OPTIONS=(1 "Update Lets Encrypt"
				 	 2 "Renew Certificates"
			 	   3 "Back"
			  	 4 "Exit")

	CHOICE=$(dialog --clear \
					--nocancel \
					--no-cancel \
					--backtitle "$BACKTITLE" \
					--title "$TITLE" \
					--menu "$MENU" \
					$HEIGHT $WIDTH $CHOICE_HEIGHT \
					"${OPTIONS[@]}" \
					2>&1 >/dev/tty)

	clear
	case $CHOICE in
			1)
        dialog --backtitle "NeXt Server Installation" --infobox "Updating Lets Encrypt" $HEIGHT $WIDTH
        source ${SCRIPT_PATH}/script/logs.sh; set_logs
        source ${SCRIPT_PATH}/script/prerequisites.sh; prerequisites
        update_lets_encrypt
        dialog --backtitle "NeXt Server Installation" --msgbox "Finished updating Lets Encrypt" $HEIGHT $WIDTH
				;;
			2)
        dialog --backtitle "NeXt Server Installation" --infobox "Renew Lets Encrypt Certs" $HEIGHT $WIDTH
        source ${SCRIPT_PATH}/script/logs.sh; set_logs
        source ${SCRIPT_PATH}/script/prerequisites.sh; prerequisites
        renew_lets_encrypt_certs
        dialog --backtitle "NeXt Server Installation" --msgbox "Finished renewing Lets Encrypt Certs" $HEIGHT $WIDTH
				;;
			3)
				bash ${SCRIPT_PATH}/start.sh;
				;;
			4)
				echo "Exit"
				exit 1
				;;
	esac
}

install_lets_encrypt() {

service nginx stop
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
cd ${SCRIPT_PATH}/sources/acme.sh/

if [[ ${USE_MAILSERVER} == '1' ]]; then
	bash acme.sh --issue --standalone -d ${MYDOMAIN} -d www.${MYDOMAIN} -d mail.${MYDOMAIN} -d imap.${MYDOMAIN} -d smtp.${MYDOMAIN} --keylength ec-384 >>"${main_log}" 2>>"${err_log}"
else
	bash acme.sh --issue --standalone -d ${MYDOMAIN} -d www.${MYDOMAIN} --keylength ec-384 >>"${main_log}" 2>>"${err_log}"
fi

ln -s /root/.acme.sh/${MYDOMAIN}_ecc/fullchain.cer /etc/nginx/ssl/${MYDOMAIN}-ecc.cer >>"${main_log}" 2>>"${err_log}"
ln -s /root/.acme.sh/${MYDOMAIN}_ecc/${MYDOMAIN}.key /etc/nginx/ssl/${MYDOMAIN}-ecc.key >>"${main_log}" 2>>"${err_log}"

HPKP1=$(openssl x509 -pubkey < /etc/nginx/ssl/${MYDOMAIN}-ecc.cer | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64) >>"${main_log}" 2>>"${err_log}"
HPKP2=$(openssl rand -base64 32) >>"${main_log}" 2>>"${err_log}"
}

update_lets_encrypt() {

  #maybe add acme.sh --upgrade --auto-upgrade?
  cd ${SCRIPT_PATH}/.acme.sh/
  acme.sh --upgrade
}

renew_lets_encrypt_certs() {

source ${SCRIPT_PATH}/configs/versions.cfg

cd ${SCRIPT_PATH}/.acme.sh/

if [[ ${USE_MAILSERVER} == '1' ]]; then
	bash acme.sh --issue --standalone -d ${MYDOMAIN} -d www.${MYDOMAIN} -d mail.${MYDOMAIN} imap.${MYDOMAIN} smtp.${MYDOMAIN} --keylength ec-384 >>"${main_log}" 2>>"${err_log}"
else
  bash acme.sh --renew -d ${MYDOMAIN} -d www.${MYDOMAIN} --force --ecc >>"${main_log}" 2>>"${err_log}"
fi
}
