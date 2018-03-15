#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

clear
echo "NeXt Server"
echo "Preparing menu..."

#-------------dialog
apt-get -qq install dialog >/dev/null 2>&1

SCRIPT_PATH="/root/NeXt-Server"

GIT_LOCAL_FILES_HEAD=$(git rev-parse --short HEAD)
GIT_LOCAL_FILES_HEAD_LAST_COMMIT=$(git log -1 --date=short --pretty=format:%cd)
source ${SCRIPT_PATH}/configs/versions.cfg
source ${SCRIPT_PATH}/script/functions.sh
source ${SCRIPT_PATH}/script/logs.sh; set_logs
source ${SCRIPT_PATH}/script/prerequisites.sh; prerequisites

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=7
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="\n Choose one of the following options: \n \n"

		OPTIONS=(1 "Install NeXt Server Version: ${GIT_LOCAL_FILES_HEAD} - ${GIT_LOCAL_FILES_HEAD_LAST_COMMIT}"
						 2 "After Installation configuration"
						 3 "Update all services"
						 4 "Update NeXt Server Script"
						 5 "Services Options"
						 6 "Addon Setup"
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
					bash install.sh
					;;
				2)
					HEIGHT=40
					WIDTH=80
					CHOICE_HEIGHT=6
					BACKTITLE="NeXt Server"
					TITLE="NeXt Server"
					MENU="Choose one of the following options:"

							OPTIONS=(1 "Full after installation configuration"
											 2 "Show SSH Key"
											 3 "Show Login information"
											 4 "Create private key"
											 5 "Back"
											 6 "Exit")

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
										source ${SCRIPT_PATH}/functions.sh; start_after_install
										;;
									2)
										source ${SCRIPT_PATH}/configuration.sh; show_ssh_key
										;;
									3)
										source ${SCRIPT_PATH}/configuration.sh; show_login_information.txt
										;;
									4)
										source ${SCRIPT_PATH}/configuration.sh; create_private_key
										;;
									5)
										bash ${SCRIPT_PATH}/nxt.sh
										;;
									6)
										echo "Exit"
										exit 1
										;;
							esac
					;;
				3)
					#check if installed, otherwise skip single services
					dialog --backtitle "NeXt Server Installation" --infobox "Updating all services" $HEIGHT $WIDTH
					source ${SCRIPT_PATH}/script/prerequisites.sh; prerequisites

					source ${SCRIPT_PATH}/script/openssh.sh; update_openssh
					source ${SCRIPT_PATH}/script/openssl.sh; update_openssl
					dialog --backtitle "NeXt Server Installation" --msgbox "Finished updating all services" $HEIGHT $WIDTH
					;;
				4)
					dialog --backtitle "NeXt Server Installation" --infobox "Updating NeXt Server Script" $HEIGHT $WIDTH
					source ${SCRIPT_PATH}/update_script.sh; update_script
					dialog --backtitle "NeXt Server Installation" --msgbox "Finished updating NeXt Server Script to Version ${GIT_LOCAL_FILES_HEAD}" $HEIGHT $WIDTH
					bash nxt.sh
					;;
				5)
					source ${SCRIPT_PATH}/menus/services_menu.sh; menu_options_services
					;;
				6)
					source ${SCRIPT_PATH}/menus/addons_menu.sh; menu_options_addons
					;;
				7)
					echo "Exit"
					exit 1
					;;
		esac
