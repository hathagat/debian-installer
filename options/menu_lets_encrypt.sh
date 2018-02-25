#!/bin/bash

menu_options_lets_encrypt() {

HEIGHT=30
WIDTH=60
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
        dialog --backtitle "NeXt Server Installation" --infobox "Updating Lets Encrypt" $HEIGHT $WIDTH
		source ${SCRIPT_PATH}/script/lets_encrypt.sh; update_lets_encrypt || error_exit
        dialog --backtitle "NeXt Server Installation" --msgbox "Finished updating Lets Encrypt" $HEIGHT $WIDTH
				;;
			2)
        dialog --backtitle "NeXt Server Installation" --infobox "Renew Lets Encrypt Certs" $HEIGHT $WIDTH
		source ${SCRIPT_PATH}/script/lets_encrypt.sh; renew_lets_encrypt_certs || error_exit
        dialog --backtitle "NeXt Server Installation" --msgbox "Finished renewing Lets Encrypt Certs" $HEIGHT $WIDTH
				;;
			3)
				dialog --backtitle "NeXt Server Installation" --infobox "Update Lets Encrypt" $HEIGHT $WIDTH
				source ${SCRIPT_PATH}/script/lets_encrypt.sh; update_lets_encrypt || error_exit
				dialog --backtitle "NeXt Server Installation" --msgbox "Finished update Lets Encrypt" $HEIGHT $WIDTH
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
