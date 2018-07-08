#!/bin/bash
# # Compatible with Debian 9.x Stretch
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
CHOICE_HEIGHT=6
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

		OPTIONS=(1 "Openssh Options"
             2 "Fail2ban Options"
             3 "Lets Encrypt Options"
             4 "Firewall Options"
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
	source ${SCRIPT_PATH}/menus/openssh_menu.sh; menu_options_openssh
	;;
2)
	source ${SCRIPT_PATH}/menus/fail2ban_menu.sh; menu_options_fail2ban
	;;
3)
	source ${SCRIPT_PATH}/menus/lets_encrypt_menu.sh; menu_options_lets_encrypt
	;;
4)
	source ${SCRIPT_PATH}/menus/firewall_menu.sh; menu_options_firewall
	;;
5)
  bash ${SCRIPT_PATH}/nxt.sh;
  ;;
6)
	echo "Exit"
	exit 1
	;;
esac

}
