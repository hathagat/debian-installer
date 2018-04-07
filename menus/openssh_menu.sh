#!/bin/bash

menu_options_openssh() {

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=7
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

	OPTIONS=(1 "Install Openssh"
			 2 "Update Openssh"
			 3 "Add new Openssh User"
			 4 "Change Openssh Port"
			 5 "Create new Openssh Key"
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
			1)
				dialog_info "Installing Openssh"
				source ${SCRIPT_PATH}/script/openssh.sh; install_openssh || error_exit
				dialog_msg "Finished installing Openssh"
				echo
				echo
				echo "You can find your SSH key at ${SCRIPT_PATH}/ssh_privatekey.txt"
				echo
				echo
				echo "Password for your ssh key = $SSH_PASS"
				echo
				echo
				echo "Your SSH Key"
				cat ${SCRIPT_PATH}/ssh_privatekey.txt
				exit 1
				;;
			2)
				dialog_info "Updating Openssh"
				source ${SCRIPT_PATH}/script/openssh.sh; update_openssh || error_exit
				dialog_msg "Finished updating Openssh"
				;;
			3)
				NEW_OPENSSH_USER=$(dialog --clear \
				--backtitle "$BACKTITLE" \
				--inputbox "Please enter the new Openssh Username:" \
				$HEIGHT $WIDTH \
				3>&1 1>&2 2>&3 3>&- \
				)
				source ${SCRIPT_PATH}/script/openssh.sh; add_openssh_user || error_exit
				dialog_msg "Finished adding Openssh User"
				;;
			4)
			while true
				do
					INPUT_NEW_SSH_PORT=$(dialog --clear \
							--backtitle "$BACKTITLE" \
							--inputbox "Enter your SSH Port (only max. 3 numbers!):" \
							$HEIGHT $WIDTH \
							3>&1 1>&2 2>&3 3>&- \
							)
					if [[ $INPUT_NEW_SSH_PORT =~ ^-?[0-9]+$ ]]; then
						if [[ -v BLOCKED_PORTS[$INPUT_NEW_SSH_PORT] ]]; then
							dialog_msg "$INPUT_NEW_SSH_PORT is known. Choose an other Port!"
							dialog --clear
						else
							NEW_SSH_PORT="$INPUT_NEW_SSH_PORT"
							echo " you port is $NEW_SSH_PORT"
							break
						fi
					else
					dialog_msg "The Port should only contain numbers!"
					dialog --clear
					fi
				done
				source ${SCRIPT_PATH}/script/openssh.sh; change_openssh_port || error_exit
				dialog_info "Changed SSH Port to $NEW_SSH_PORT"
				;;
			5)
				dialog_info "Creating new Openssh key"
				source ${SCRIPT_PATH}/script/openssh.sh; create_new_openssh_key || error_exit
				dialog_msg "Finished creating new ssh key"
				echo
				echo
				echo "You can find your New SSH key at ${SCRIPT_PATH}/ssh_privatekey.txt"
				echo
				echo
				echo "Password for your new ssh key = $NEW_SSH_PASS"
				echo
				echo
				echo "Your new SSH Key"
				cat ${SCRIPT_PATH}/ssh_privatekey.txt
				exit 1
				;;
			6)
				bash ${SCRIPT_PATH}/nxt.sh;
				;;
			7)
				echo "Exit"
				exit 1
				;;
	esac
}
