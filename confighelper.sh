#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script! 
#-------------------------------------------------------------------------------------------------------------

confighelper_userconfig() {

# --- GLOBAL MENU VARIABLES ---
BACKTITLE="NeXt Server Installation"
TITLE="NeXt Server Installation"
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
source ${SCRIPT_PATH}/script/functions.sh; get_domain

CHOICE_HEIGHT=2
MENU="Is this the domain, you want to use? ${DETECTED_DOMAIN}:"
OPTIONS=(1 "Yes"
		     2 "No")
menu
clear
case $CHOICE in
      1)
			MYDOMAIN=${DETECTED_DOMAIN}
            ;;
		2)
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
            ;;
esac

# --- DNS Check ---

server_ip=$(ip route get 9.9.9.9 | awk '/9.9.9.9/ {print $NF}')
sed -i "s/server_ip/$server_ip/g" ${SCRIPT_PATH}/dns_settings.txt
sed -i "s/yourdomain.com/$MYDOMAIN/g" ${SCRIPT_PATH}/dns_settings.txt
dialog --title "DNS Settings" --tab-correct --textbox ${SCRIPT_PATH}/dns_settings.txt 50 200

BACKTITLE="NeXt Server Installation"
TITLE="NeXt Server Installation"
HEIGHT=15
WIDTH=70

CHOICE_HEIGHT=2
MENU="Have you set the DNS Settings 24-48 hours before running this Script?:"
OPTIONS=(1 "Yes"
		 2 "No")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
				--no-cancel \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
	1)
		;;
	2)
		dialog --backtitle "NeXt Server Installation" --msgbox "Sorry, you have to wait 24 - 48 hours, until the DNS system knows your settings!" $HEIGHT $WIDTH
		exit 1
		;;
esac

source ${SCRIPT_PATH}/script/functions.sh; setipaddrvars
if [[ ${FQDNIP} != ${IPADR} ]]; then
	echo "${MYDOMAIN} (${FQDNIP}) does not resolve to the IP address of your server (${IPADR})"
	exit 1
fi

if [ ${CHECKRDNS} != mail.${MYDOMAIN} ] | [ ${CHECKRDNS} != mail.${MYDOMAIN}. ]; then
	echo "Your reverse DNS (${CHECKRDNS}) does not match the SMTP Banner. Please set your Reverse DNS to mail.$MYDOMAIN"
	exit 1
fi

CHECK_E_MAIL="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z])?\$"
while true
	do
		NXT_SYSTEM_EMAIL=$(dialog --clear \
		--backtitle "$BACKTITLE" \
		--inputbox "Enter your Email adress for system services example: nextserver@gmail.com" \
		$HEIGHT $WIDTH \
		3>&1 1>&2 2>&3 3>&- \
		)
			if [[ "$NXT_SYSTEM_EMAIL" =~ $CHECK_E_MAIL ]];then
				break
			else
				dialog --title "NeXt Server Confighelper" --msgbox "[ERROR] Should we again practice how a Email address looks?" $HEIGHT $WIDTH
				dialog --clear
			fi
	done

# --- Mailserver ---
CHOICE_HEIGHT=2
MENU="Do you want to use the Mailserver?:"
OPTIONS=(1 "Yes"
		     2 "No")
menu
clear
case $CHOICE in
      1)
			USE_MAILSERVER="1"
            ;;
		2)
			USE_MAILSERVER="0"
            ;;
esac

# --- PHP ---
CHOICE_HEIGHT=3
MENU="Do you want to Use PHP 5.6, 7.1 or PHP 7.2?:"
OPTIONS=(1 "PHP 5"
				 2 "PHP 7.1"
		     3 "PHP 7.2")
menu
clear
case $CHOICE in
    1)
		USE_PHP5="1"
		USE_PHP7_1="0"
		USE_PHP7_2="0"
		PHPVERSION7="5"
          ;;
		2)
		USE_PHP5="0"
		USE_PHP7_1="1"
		USE_PHP7_2="0"
		PHPVERSION7="7.1"
          ;;
		3)
		USE_PHP5="0"
		USE_PHP7_1="0"
		USE_PHP7_2="1"
		PHPVERSION7="7.2"
            ;;
esac

CONFIG_COMPLETED="1"

GIT_LOCAL_FILES_HEAD=$(git rev-parse --short HEAD)
rm -rf ${SCRIPT_PATH}/configs/userconfig.cfg
cat >> ${SCRIPT_PATH}/configs/userconfig.cfg <<END
#-----------------------------------------------------------#
############### Config File from Confighelper ###############
#-----------------------------------------------------------#
# This file was created on ${CURRENT_DATE} with NeXt Server Version ${GIT_LOCAL_FILES_HEAD}

	CONFIG_COMPLETED="${CONFIG_COMPLETED}"
	TIMEZONE="${TIMEZONE}"
	MYDOMAIN="${MYDOMAIN}"
	USE_MAILSERVER="${USE_MAILSERVER}"
	USE_PHP5="${USE_PHP5}"
	USE_PHP7_1="${USE_PHP7_1}"
	USE_PHP7_2="${USE_PHP7_2}"
	PHPVERSION7="${PHPVERSION7}"

	MYSQL_HOSTNAME="localhost"

	NXT_SYSTEM_EMAIL="${NXT_SYSTEM_EMAIL}"
	NXT_IS_INSTALLED="0"
	NXT_IS_INSTALLED_MAILSERVER_STANDALONE="0"
	NXT_INSTALL_DATE="0"
#-----------------------------------------------------------#
############### Config File from Confighelper ###############
#-----------------------------------------------------------#
END

dialog --title "Userconfig" --textbox ${SCRIPT_PATH}/configs/userconfig.cfg 50 250
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
				confighelper_userconfig
        ;;
esac
}
