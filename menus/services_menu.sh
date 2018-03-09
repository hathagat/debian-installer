#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

menu_options_services() {

SCRIPT_PATH="/root/NeXt-Server"

source ${SCRIPT_PATH}/configs/versions.cfg
source ${SCRIPT_PATH}/script/functions.sh
source ${SCRIPT_PATH}/script/logs.sh; set_logs
source ${SCRIPT_PATH}/script/prerequisites.sh; prerequisites

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=10
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

		OPTIONS=(1 "Mailserver Options"
             2 "Openssh Options"
             3 "Openssl Options"
             4 "Fail2ban Options"
             5 "Nginx vHost Options"
             6 "PHP 7.x Options"
             7 "Lets Encrypt Options"
             8 "Firewall Options"
             9 "Back"
						10 "Exit")

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
	source ${SCRIPT_PATH}/options/mailserver_menu.sh; menu_options_mailserver
	;;
2)
	source ${SCRIPT_PATH}/options/openssh_menu.sh; menu_options_openssh
	;;
3)
	source ${SCRIPT_PATH}/options/openssl_menu.sh; menu_options_openssl
	;;
4)
	source ${SCRIPT_PATH}/options/fail2ban_menu.sh; menu_options_fail2ban
	;;
5)
	source ${SCRIPT_PATH}/options/vhost_menu.sh; menu_options_nginx_vhost
	;;
6)
	source ${SCRIPT_PATH}/options/php_7_x_menu.sh; php_7_x_config
	;;
7)
	source ${SCRIPT_PATH}/options/lets_encrypt_menu.sh; menu_options_lets_encrypt
	;;
8)
	source ${SCRIPT_PATH}/options/firewall_menu.sh; menu_options_firewall
	;;
9)
  bash ${SCRIPT_PATH}/nxt.sh;
  ;;
10)
	echo "Exit"
	exit 1
	;;
esac

}
