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
CHOICE_HEIGHT=7
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

	OPTIONS=(1 "Install Mailserver Standalone"
			 2 "Update Mailserver"
			 3 "Add new Domain"
			 4 "Add Email Account (WIP!)"
			 5 "Add Alias (WIP!)"
			 6 "Back"
			 7 "Exit")

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
        source ${SCRIPT_PATH}/script/unbound.sh; install_unbound
        source ${SCRIPT_PATH}/script/mailserver.sh; install_mailserver
        source ${SCRIPT_PATH}/script/dovecot.sh; install_dovecot
        source ${SCRIPT_PATH}/script/postfix.sh; install_postfix
        source ${SCRIPT_PATH}/script/rspamd.sh; install_rspamd

				source ${SCRIPT_PATH}/configuration.sh; show_login_information
				read -p "Continue (y/n)?" ANSW
				if [ "$ANSW" = "n" ]; then
					echo "Exit"
					exit 1
				fi

				source ${SCRIPT_PATH}/configuration.sh; show_dkim_key
        dialog --backtitle "NeXt Server Installation" --msgbox "Finished installing Standalone Mailserver" $HEIGHT $WIDTH
				;;
			2)
				dialog --backtitle "NeXt Server Installation" --infobox "Updating Mailserver" $HEIGHT $WIDTH
				apt-get update >/dev/null 2>&1
				apt-get -y upgrade >>"${main_log}" 2>>"${err_log}"
				dialog --backtitle "NeXt Server Installation" --msgbox "Finished updating Mailserver" $HEIGHT $WIDTH
				;;
			3)
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
					EMAIL_USER_NAME=$(dialog --clear \
					--backtitle "$BACKTITLE" \
					--inputbox "Enter your Email User ("admin" for example)" \
					$HEIGHT $WIDTH \
					3>&1 1>&2 2>&3 3>&- \
					)

				SCRIPT_PATH="/root/NeXt-Server"
				source ${SCRIPT_PATH}/script/functions.sh
				source ${SCRIPT_PATH}/configs/versions.cfg
				EMAIL_ACCOUNT_PASS=$(password)
				echo  "Your Email User Name: $EMAIL_USER_NAME" >> ${SCRIPT_PATH}/login_information
				echo  "Your Email Account password: $EMAIL_ACCOUNT_PASS" >> ${SCRIPT_PATH}/login_information

				EMAIL_ACCOUNT_PASS_HASH=$(doveadm pw -p ${EMAIL_ACCOUNT_PASS} -s SHA512-CRYPT)
				mysql -u root -e "use vmail; insert into accounts (username, domain, password, quota, enabled, sendonly) values ('${EMAIL_USER_NAME}', '${MYDOMAIN}', '${EMAIL_ACCOUNT_PASS_HASH}', 2048, true, false);"
				dialog --backtitle "NeXt Server Installation" --msgbox "Added ${EMAIL_USER_NAME} with the password: ${EMAIL_ACCOUNT_PASS} to the Mailserver" $HEIGHT $WIDTH
				;;
			5)
					EMAIL_USER_NAME=$(dialog --clear \
					--backtitle "$BACKTITLE" \
					--inputbox "Enter your Email User Name, you created and that should get the alias (if you haven't created a user yet, do it before this step!)" \
					$HEIGHT $WIDTH \
					3>&1 1>&2 2>&3 3>&- \
					)

					EMAIL_ALIAS_NAME=$(dialog --clear \
					--backtitle "$BACKTITLE" \
					--inputbox "Enter the Alias Name for the Email user (for example "postmaster")" \
					$HEIGHT $WIDTH \
					3>&1 1>&2 2>&3 3>&- \
					)
				source ${SCRIPT_PATH}/script/functions.sh
				source ${SCRIPT_PATH}/configs/versions.cfg
				mysql -u root -e "use vmail; insert into aliases (source_username, source_domain, destination_username, destination_domain, enabled) values ('${EMAIL_ALIAS_NAME}', '${MYDOMAIN}', '${EMAIL_USER_NAME}', '${MYDOMAIN}', true);"
				dialog --backtitle "NeXt Server Installation" --msgbox "Added Alias ${EMAIL_ALIAS_NAME} to the Email User ${EMAIL_USER_NAME}" $HEIGHT $WIDTH
				;;
			6)
				bash ${SCRIPT_PATH}/start.sh;
				;;
			7)
				echo "Exit"
				exit 1
				;;
	esac
}

install_mailserver() {

systemctl -q stop nginx.service

SCRIPT_PATH="/root/NeXt-Server"

cd ${SCRIPT_PATH}/sources/acme.sh/
bash acme.sh --issue --standalone -d mail.${MYDOMAIN} -d imap.${MYDOMAIN} -d smtp.${MYDOMAIN} --keylength 4096 >>"${main_log}" 2>>"${err_log}"
ln -s /root/.acme.sh/mail.${MYDOMAIN}/fullchain.cer /etc/nginx/ssl/mail.${MYDOMAIN}.cer
ln -s /root/.acme.sh/mail.${MYDOMAIN}/mail.${MYDOMAIN}.key /etc/nginx/ssl/mail.${MYDOMAIN}.key

systemctl -q start nginx.service

MAILSERVER_DB_PASS=$(password)
echo  "Mailserver DB Password: $MAILSERVER_DB_PASS" >> ${SCRIPT_PATH}/login_information

sed -i "s/placeholder/${MAILSERVER_DB_PASS}/g" ${SCRIPT_PATH}/configs/mailserver/database.sql
mysql -u root mysql < ${SCRIPT_PATH}/configs/mailserver/database.sql

adduser --gecos "" --disabled-login --disabled-password --home /var/vmail vmail >>"${main_log}" 2>>"${err_log}"

mkdir -p /var/vmail/mailboxes
mkdir -p /var/vmail/sieve/global
chown -R vmail /var/vmail
chgrp -R vmail /var/vmail
chmod -R 770 /var/vmail

}
