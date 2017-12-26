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

menu_options_mailserver() {

HEIGHT=30
WIDTH=60
CHOICE_HEIGHT=6
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

	OPTIONS=(1 "Install Mailserver Standalone"
			 2 "Update Mailserver"
			 3 "Add new Domain"
			 4 "Add Email Account (WIP!)"
			 5 "Back"
			 6 "Exit")

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
        # --- MYDOMAIN ---
        while true
          do
            MYDOMAIN=$(dialog --clear \
            --backtitle "$BACKTITLE" \
            --inputbox "Enter your Domain without http:// (exmaple.org):" \
            $HEIGHT $WIDTH \
            3>&1 1>&2 2>&3 3>&- \
            )
              if [[ "$MYDOMAIN" =~ $CHECK_DOMAIN ]];then
                break
              else
                dialog --title "NeXt Server Confighelper" --msgbox "[ERROR] Should we again practice how a Domain address looks?" $HEIGHT $WIDTH
                dialog --clear
              fi
          done
        dialog --backtitle "NeXt Server Installation" --infobox "Install Standalone Mailserver" $HEIGHT $WIDTH
        source ${SCRIPT_PATH}/script/logs.sh; set_logs
        source ${SCRIPT_PATH}/script/functions.sh
        source ${SCRIPT_PATH}/script/prerequisites.sh; prerequisites
        source ${SCRIPT_PATH}/script/functions.sh; setipaddrvars
        source ${SCRIPT_PATH}/configs/versions.cfg

        source ${SCRIPT_PATH}/script/openssl.sh; install_openssl
        source ${SCRIPT_PATH}/script/mariadb.sh; install_mariadb
        source ${SCRIPT_PATH}/script/lets_encrypt.sh; install_lets_encrypt
        #später 7.1 or 7.2
        #source ${SCRIPT_PATH}/script/php7_1.sh; install_php_7_1
        source ${SCRIPT_PATH}/script/unbound.sh; install_unbound
        source ${SCRIPT_PATH}/script/mailserver.sh; install_mailserver
        source ${SCRIPT_PATH}/script/dovecot.sh; install_dovecot
        source ${SCRIPT_PATH}/script/postfix.sh; install_postfix
        source ${SCRIPT_PATH}/script/rspamd.sh; install_rspamd
        #source ${SCRIPT_PATH}/script/rainloop.sh; install_rainloop

        dialog --backtitle "NeXt Server Installation" --msgbox "Finished installing Standalone Mailserver" $HEIGHT $WIDTH
				;;
			2)
				dialog --backtitle "NeXt Server Installation" --infobox "Updating Mailserver" $HEIGHT $WIDTH
				dialog --backtitle "NeXt Server Installation" --msgbox "Finished updating Mailserver" $HEIGHT $WIDTH
				;;
			3)
        # --- MYDOMAIN ---
        while true
          do
            MYDOMAIN=$(dialog --clear \
            --backtitle "$BACKTITLE" \
            --inputbox "Enter your Domain without http:// (exmaple.org):" \
            $HEIGHT $WIDTH \
            3>&1 1>&2 2>&3 3>&- \
            )
              if [[ "$MYDOMAIN" =~ $CHECK_DOMAIN ]];then
                break
              else
                dialog --title "NeXt Server Confighelper" --msgbox "[ERROR] Should we again practice how a Domain address looks?" $HEIGHT $WIDTH
                dialog --clear
              fi
          done
        mysql -u root -e "use vmail; insert into domains (domain) values ('${MYDOMAIN}');"
        dialog --backtitle "NeXt Server Installation" --msgbox "Added domain ${MYDOMAIN} to the Mailserver" $HEIGHT $WIDTH
				;;
			4)
				#check if domain is created
				;;
			5)
				bash ${SCRIPT_PATH}/start.sh;
				;;
			6)
				echo "Exit"
				exit 1
				;;
	esac
}

install_mailserver() {

set -x
cd ${SCRIPT_PATH}/sources/acme.sh/
bash acme.sh --issue --standalone -d mail.${MYDOMAIN} -d imap.${MYDOMAIN} -d smtp.${MYDOMAIN} --keylength 4096 >>"${main_log}" 2>>"${err_log}"
ln -s /root/.acme.sh/mail.${MYDOMAIN}/fullchain.cer /etc/nginx/ssl/mail.${MYDOMAIN}.cer
ln -s /root/.acme.sh/mail.${MYDOMAIN}/mail.${MYDOMAIN}.key /etc/nginx/ssl/mail.${MYDOMAIN}.key

mysql -u root mysql < ${SCRIPT_PATH}/configs/mailserver/database.sql
#change placeholder

adduser --gecos "" --disabled-login --disabled-password --home /var/vmail vmail

mkdir -p /var/vmail/mailboxes
mkdir -p /var/vmail/sieve/global
chown -R vmail /var/vmail
chgrp -R vmail /var/vmail
chmod -R 770 /var/vmail

}
