#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

menu_options_fail2ban() {

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=5
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

	OPTIONS=(1 "Install fail2ban"
			 2 "Update fail2ban"
			 3 "Activate fail2ban jails"
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
				dialog_info "Installing fail2ban"
				source ${SCRIPT_PATH}/script/fail2ban.sh; install_fail2ban || error_exit
				dialog_msg "Finished installing fail2ban"
				exit 1
				;;
			2)
				dialog_info "Updating fail2ban"
			  source ${SCRIPT_PATH}/script/fail2ban.sh; update_fail2ban || error_exit
				dialog_msg "Finished updating fail2ban"
				;;
			3)
				dialog_info "Activating fail2ban jails"
				source ${SCRIPT_PATH}/service-options/fail2ban_options.sh; activate_fail2ban_jails || error_exit
				dialog_msg "Finished activating fail2ban jails"
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
