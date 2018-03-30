#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

menu_options_openssl() {

HEIGHT=40
WIDTH=80
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
				dialog_info "Installing Openssl"
				source ${SCRIPT_PATH}/script/openssl.sh; install_openssl || error_exit
				dialog_msg "Finished installing Openssl"
				exit 1
				;;
			2)
				dialog_info "Updating Openssl"
				source ${SCRIPT_PATH}/script/openssl.sh; update_openssl || error_exit
				dialog_msg "Finished updating Openssl"
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
