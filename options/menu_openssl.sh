#!/bin/bash

menu_options_openssl() {

HEIGHT=30
WIDTH=60
CHOICE_HEIGHT=4
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

	OPTIONS=(1 "Install Openssl"
			 2 "Update Openssl"
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
				dialog --backtitle "NeXt Server Installation" --infobox "Installing Openssl" $HEIGHT $WIDTH
				source ${SCRIPT_PATH}/script/openssl.sh; install_openssl || error_exit
				dialog --backtitle "NeXt Server Installation" --msgbox "Finished installing Openssl" $HEIGHT $WIDTH
				exit 1
				;;
			2)
				dialog --backtitle "NeXt Server Installation" --infobox "Updating Openssl" $HEIGHT $WIDTH
				source ${SCRIPT_PATH}/script/openssl.sh; update_openssl || error_exit
				dialog --backtitle "NeXt Server Installation" --msgbox "Finished updating Openssl" $HEIGHT $WIDTH
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
