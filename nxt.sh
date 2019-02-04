#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

clear
echo "NeXt Server"
echo "Preparing menu..."

if [ $(dpkg-query -l | grep dialog | wc -l) -ne 3 ]; then
	apt-get -qq install dialog >/dev/null 2>&1
fi

SCRIPT_PATH="/root/NeXt-Server"

GIT_LOCAL_FILES_HEAD=$(git rev-parse --short HEAD)
GIT_LOCAL_FILES_HEAD_LAST_COMMIT=$(git log -1 --date=short --pretty=format:%cd)
source ${SCRIPT_PATH}/configs/versions.cfg
source ${SCRIPT_PATH}/configs/userconfig.cfg
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
						 3 "!Update NeXt Server Installation (do not use yet!)"
						 4 "Update NeXt Server Script Code Base"
						 5 "Services Options"
						 6 "Addon Installation"
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
					if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
						echo "The NeXt-Server Script is already installed!"
						source ${SCRIPT_PATH}/script/functions.sh; continue_to_menu
					else
						bash install.sh
					fi
					;;
				2)
					if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
						echo "Please install the NeXt-Server Script before starting the configuration!"
						source ${SCRIPT_PATH}/menus/after_install_config_menu.sh; menu_options_after_install
					else
						source ${SCRIPT_PATH}/script/functions.sh; continue_to_menu
					fi
					;;
				3)
					if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
						source ${SCRIPT_PATH}/updates/all-services-update.sh; update_all_services
					else
						echo "You have to install the NeXt Server to run the services update!"
						source ${SCRIPT_PATH}/script/functions.sh; continue_to_menu
					fi
					;;
				4)
					dialog_info "Updating NeXt Server Script"
					source ${SCRIPT_PATH}/update_script.sh; update_script
					dialog_msg "Finished updating NeXt Server Script to Version ${GIT_LOCAL_FILES_HEAD}"
					bash nxt.sh
					;;
				5)
					if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
						source ${SCRIPT_PATH}/menus/services_menu.sh; menu_options_services
					else
						echo "You have to install the NeXt Server to run the services options!"
						source ${SCRIPT_PATH}/script/functions.sh; continue_to_menu
					fi
					;;
				6)
					if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
						source ${SCRIPT_PATH}/menus/addons_menu.sh; menu_options_addons
					else
						echo "You have to install the NeXt Server to install addons!"
						source ${SCRIPT_PATH}/script/functions.sh; continue_to_menu
					fi
					;;
				7)
					echo "Exit"
					exit 1
					;;
		esac
