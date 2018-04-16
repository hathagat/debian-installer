#!/bin/bash

menu_options_fail2ban() {

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=3
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

	OPTIONS=(1 "Activate fail2ban jails"
			 2 "Back"
			 3 "Exit")

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
				dialog_info "Activating fail2ban jails"
				source ${SCRIPT_PATH}/script/fail2ban_options.sh; activate_fail2ban_jails || error_exit
				dialog_msg "Finished activating fail2ban jails"
				;;
			2)
				bash ${SCRIPT_PATH}/nxt.sh;
				;;
			3)
				echo "Exit"
				exit 1
				;;
	esac
}
