#!/bin/bash

menu_options_nginx_vhost() {

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=4
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

	OPTIONS=(1 "Placeholder"
				 	 2 "Placeholder"
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
				echo "Placeholder"
				;;
			2)
				echo "Placeholder"
				;;
			3)
				bash ${SCRIPT_PATH}/nxt.sh;
				;;
			4)
				echo "Exit"
				exit 1
				;;
	esac
}
