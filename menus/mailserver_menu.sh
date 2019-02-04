#!/bin/bash
# Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

menu_options_mailserver() {

trap error_exit ERR

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=7
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

	OPTIONS=(1 "List all known accounts and aliases."
			 2 "Add an account."
			 3 "Change settings of an account."
       4 "Change password of an account."
       5 "Delete an account."
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

######### add arguments + dialog input before doing the magic

			1)
				cd /etc/managevmail/
				./managevmail.py list
				source ${SCRIPT_PATH}/script/functions.sh; continue_or_exit
        source ${SCRIPT_PATH}/menus/mailserver_menu.sh; menu_options_mailserver
				;;
			2)
				CREATE_EMAIL_ADDRESS=$(dialog --clear \
				--backtitle "$BACKTITLE" \
				--inputbox "Enter the Email address you want to create (Example: admin@domain.com):" \
				$HEIGHT $WIDTH \
				3>&1 1>&2 2>&3 3>&- \
				)
				cd /etc/managevmail/
        ./managevmail.py add $CREATE_EMAIL_ADDRESS
				source ${SCRIPT_PATH}/script/functions.sh; continue_or_exit
        source ${SCRIPT_PATH}/menus/mailserver_menu.sh; menu_options_mailserver
				;;
			3)
				CHANGE_EMAIL_ADDRESS=$(dialog --clear \
				--backtitle "$BACKTITLE" \
				--inputbox "Enter the Email address you want to change (Example: admin@domain.com):" \
				$HEIGHT $WIDTH \
				3>&1 1>&2 2>&3 3>&- \
				)
				cd /etc/managevmail/
        ./managevmail.py change $CHANGE_EMAIL_ADDRESS
				source ${SCRIPT_PATH}/script/functions.sh; continue_or_exit
        source ${SCRIPT_PATH}/menus/mailserver_menu.sh; menu_options_mailserver
        ;;
      4)
				CHANGE_EMAIL_ADDRESS_PASSWORD=$(dialog --clear \
				--backtitle "$BACKTITLE" \
				--inputbox "Enter the Email address you want to change the password (Example: admin@domain.com):" \
				$HEIGHT $WIDTH \
				3>&1 1>&2 2>&3 3>&- \
				)
				cd /etc/managevmail/
        ./managevmail.py pw $CHANGE_EMAIL_ADDRESS_PASSWORD
				source ${SCRIPT_PATH}/script/functions.sh; continue_or_exit
        source ${SCRIPT_PATH}/menus/mailserver_menu.sh; menu_options_mailserver
        ;;
      5)
				DELETE_EMAIL_ADDRESS=$(dialog --clear \
				--backtitle "$BACKTITLE" \
				--inputbox "Enter the Email address you want to delete (Example: admin@domain.com):" \
				$HEIGHT $WIDTH \
				3>&1 1>&2 2>&3 3>&- \
				)
				cd /etc/managevmail/
        ./managevmail.py delete $DELETE_EMAIL_ADDRESS
				source ${SCRIPT_PATH}/script/functions.sh; continue_or_exit
        source ${SCRIPT_PATH}/menus/mailserver_menu.sh; menu_options_mailserver
        ;;
      6)
        bash ${SCRIPT_PATH}/nxt.sh
        ;;
      7)
        echo "Exit"
        exit 1
        ;;
	esac
}
