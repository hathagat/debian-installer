#!/bin/bash

menu_options_mailserver() {

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=3
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

	OPTIONS=(1 "Update Mailserver"
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
				dialog_info "Updating Mailserver"
				apt-get update >/dev/null 2>&1
				apt-get -y upgrade >>"${main_log}" 2>>"${err_log}"
				dialog_msg "Finished updating Mailserver"
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