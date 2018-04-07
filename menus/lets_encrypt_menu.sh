#!/bin/bash

menu_options_lets_encrypt() {

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=5
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

	OPTIONS=(1 "Update Lets Encrypt"
				 	 2 "Renew Certificates"
					 3 "Update Lets Encrypt"
			 	   4 "Back"
			  	 5 "Exit")

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
        dialog_info "Updating Lets Encrypt"
				source ${SCRIPT_PATH}/script/lets_encrypt.sh; update_lets_encrypt || error_exit
        dialog_msg "Finished updating Lets Encrypt"
				;;
			2)
        dialog_info "Renew Lets Encrypt Certs"
				source ${SCRIPT_PATH}/script/lets_encrypt.sh; renew_lets_encrypt_certs || error_exit
        dialog_msg "Finished renewing Lets Encrypt Certs"
				;;
			3)
				dialog_info "Update Lets Encrypt"
				source ${SCRIPT_PATH}/script/lets_encrypt.sh; update_lets_encrypt || error_exit
				dialog_msg "Finished update Lets Encrypt"
				;;
			4)
				bash ${SCRIPT_PATH}/nxt.sh;
				;;
			5)
				echo "Exit"
				exit 1
				;;
	esac
}
