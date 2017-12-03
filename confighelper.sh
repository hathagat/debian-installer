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

CONFIGHELPER_PATH="/root"
source $CONFIGHELPER_PATH/script/security.sh
source $CONFIGHELPER_PATH/script/functions.sh

# --- CONFIGHELPER USERCONFIG ---
confighelper_userconfig() {

# --- GLOBAL MENU VARIABLES ---
BACKTITLE="Perfect Root Server Installation"
TITLE="Perfect Root Server Installation"
HEIGHT=30
WIDTH=60

# --- TIMEZONE ---
CHOICE_HEIGHT=12
MENU="Choose a timezone:"
OPTIONS=(1 "Berlin GMT/UTC +1"
		 2 "Vienna GMT/UTC +1"
		 3 "Moscow GMT/UTC +3"
		 4 "Lisbon GMT/UTC +0"
		 5 "London GMT/UTC +0"
		 6 "Paris GMT/UTC +1"
		 7 "Rome GMT/UTC +1"
		 8 "Sydney GMT/UTC +10"
		 9 "Tokyo GMT/UTC +9"
		10 "Istanbul GMT/UTC +3"
		11 "Los_Angeles GMT/UTC -8"
		12 "New_York GMT/UTC -5")
menu
clear
case $CHOICE in
        1)
			TIMEZONE="Europe/Berlin"
            ;;
		2)
			TIMEZONE="Europe/Vienna"
            ;;
		3)
			TIMEZONE="Europe/Moscow"
            ;;
		4)
			TIMEZONE="Europe/Lisbon"
            ;;
		5)
			TIMEZONE="Europe/London"
            ;;
		6)
			TIMEZONE="Europe/Paris"
            ;;
		7)
			TIMEZONE="Europe/Rome"
            ;;
		8)
			TIMEZONE="Australia/Sydney"
            ;;
		9)
			TIMEZONE="Asia/Tokyo"
            ;;
		10)
			TIMEZONE="Asia/Istanbul"
            ;;
		11)
			TIMEZONE="America/Los_Angeles"
            ;;
        12)
			TIMEZONE="America/New_York"
            ;;
esac

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
					dialog --title "Perfectrootserver Confighelper" --msgbox "[ERROR] Should we again practice how a Domain address looks?" $HEIGHT $WIDTH
					dialog --clear
				fi
		done

# --- MAILSERVER ---
CHOICE_HEIGHT=3
MENU="Do you want to Use Mailserver?:"
OPTIONS=(1 "Yes"
		     2 "Yes with Webmail"
         3 "No")
menu
clear
case $CHOICE in
        1)
			USE_MAILSERVER="1"
			USE_WEBMAIL="0"
            ;;
        2)
			USE_MAILSERVER="1"
			USE_WEBMAIL="1"
            ;;
		3)
			USE_MAILSERVER="0"
			USE_WEBMAIL="0"
            ;;
esac

# --- PHP ---
CHOICE_HEIGHT=3
MENU="Do you want to Use PHP 7.1 or PHP 7.2?:"
OPTIONS=(1 "PHP 7.1"
		     2 "PHP 7.2")
menu
clear
case $CHOICE in
      1)
			USE_PHP7_1="1"
			USE_PHP7_2="0"
			PHPVERSION7="7.1"
            ;;
		2)
			USE_PHP7_1="0"
			USE_PHP7_2="1"
			PHPVERSION7="7.2"
            ;;
esac

	# --- SEND SERVER LOGIN VIA EMAIL ---
CHOICE_HEIGHT=2
MENU="Do you want to send the server login data via encryptet GPG Email?:"
OPTIONS=(1 "Yes"
         2 "No")
menu
clear
case $CHOICE in
        1)
			while true
			do
				USE_ENCRYPTED_LOGIN_MAIL="1"
				LOGIN_DATA_MAIL=$(dialog --clear \
				--backtitle "$BACKTITLE" \
				--inputbox "Enter your valid E-Mail address:" \
				$HEIGHT $WIDTH \
				3>&1 1>&2 2>&3 3>&- \
				)
					if [[ "$LOGIN_DATA_MAIL" =~ $CHECK_E_MAIL ]];then
						break
					else
						dialog --title "Perfectrootserver Confighelper" --msgbox "[ERROR] Should we again practice how an e-mail address looks?" $HEIGHT $WIDTH
						dialog --clear
					fi
			done

			while true
			do
				LOGIN_DATA_MAIL_PW=$(dialog --clear \
							--backtitle "$BACKTITLE" \
							--inputbox "Please choose an password for the GPG encryption of the server login data: \
							Only letters (aBc) and numbers (123) allowed! The minimum password length should be 10! " \
							$HEIGHT $WIDTH \
							3>&1 1>&2 2>&3 3>&- \
						)
				if [[ "$LOGIN_DATA_MAIL_PW" =~ $CHECK_PASSWORD ]];then
						break
					else
						dialog --title "Perfectrootserver Confighelper" --msgbox "[ERROR] Should we practice how letters and numbers look like?" $HEIGHT $WIDTH
						dialog --clear
					fi
			done
           ;;
        2)
			USE_ENCRYPTED_LOGIN_MAIL="0"
           ;;
esac

	# --- NGINX MODULES ---
	BACKTITLE="Perfect Root Server Installation"
	TITLE="Nginx Modules"

	RESULTS=$(dialog --stdout --backtitle "$BACKTITLE" --title "$TITLE" \
	 --checklist "Waehle die zu installierenden Nginx Module aus" 0 0 0 \
			01 "Brotli" off \
			02 "Autoindex" off )
	for RESULT in $RESULTS
	do
			case $RESULT in
					"01" )
							USE_BROTLI="1"
							;;
					"02" )
							USE_AUTOINDEX="1"
							;;
			esac
	done

# --- ADDONCONFIG? ---
CHOICE_HEIGHT=2
MENU="Do You need Addonconfig?:"
OPTIONS=(1 "Yes"
         2 "No")
menu
clear
case $CHOICE in
        1)
			ADDONCONFIG_COMPLETED="0"
            ;;
        2)
			ADDONCONFIG_COMPLETED="2"
            ;;
esac

CONFIG_COMPLETED="1"

rm -rf $CONFIGHELPER_PATH/configs/userconfig.cfg
cat >> $CONFIGHELPER_PATH/configs/userconfig.cfg <<END
#-----------------------------------------------------------#
############### Config File from Confighelper ###############
#-----------------------------------------------------------#
# This file was created on ${CURRENT_DATE} with PRS Version ${PRS_VERSION}

	CONFIG_COMPLETED="${CONFIG_COMPLETED}"
	TIMEZONE="${TIMEZONE}"
	MYDOMAIN="${MYDOMAIN}"
	SSH_PORT="${SSH_PORT}"
	LOGIN_DATA_MAIL="${LOGIN_DATA_MAIL}"
	USE_ENCRYPTED_LOGIN_MAIL="${USE_ENCRYPTED_LOGIN_MAIL}"
	USE_MAILSERVER="${USE_MAILSERVER}"
	USE_WEBMAIL="${USE_WEBMAIL}"
	USE_PHP7_1="${USE_PHP7_1}"
	USE_PHP7_2="${USE_PHP7_2}"
	PHPVERSION7="${PHPVERSION7}"
	USE_PMA="${USE_PMA}"
	PMA_HTTPAUTH_USER="${PMA_HTTPAUTH_USER}"
	MYSQL_PMADB_NAME="${MYSQL_PMADB_NAME}"
	MYSQL_PMADB_USER="${MYSQL_PMADB_USER}"

	#NGINX MODULES
	USE_BROTLI="${USE_BROTLI}"
	USE_AUTOINDEX="${USE_AUTOINDEX}"

	# Passwords
	LOGIN_DATA_MAIL_PW="${LOGIN_DATA_MAIL_PW}"
	SSH_PASS="${SSH_PASS}"
	POSTFIX_ADMIN_PASS="${POSTFIX_ADMIN_PASS}"
	VIMB_MYSQL_PASS="${VIMB_MYSQL_PASS}"
	ROUNDCUBE_MYSQL_PASS="${ROUNDCUBE_MYSQL_PASS}"
	PMA_HTTPAUTH_PASS="${PMA_HTTPAUTH_PASS}"
	PMA_BFSECURE_PASS="${PMA_BFSECURE_PASS}"
	MYSQL_ROOT_PASS="${MYSQL_ROOT_PASS}"
	MYSQL_PMADB_PASS="${MYSQL_PMADB_PASS}"

	MYSQL_HOSTNAME="localhost"
#-----------------------------------------------------------#
############### Config File from Confighelper ###############
#-----------------------------------------------------------#
END

dialog --title "Userconfig" --textbox $CONFIGHELPER_PATH/configs/userconfig.cfg 50 250
clear

CHOICE_HEIGHT=2
MENU="Settings correct?"
OPTIONS=(1 "Yes"
         2 "No")
menu
clear
case $CHOICE in
        1)
			#break
            ;;
        2)
			confighelper_generate_passwords
			confighelper_userconfig
            ;;
esac
}
