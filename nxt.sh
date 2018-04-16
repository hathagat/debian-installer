#!/bin/bash

clear
echo "Debian Installer"
if [[ $EUID -ne 0 ]]; then
   echo "Aborting! This script must be run as root..." 1>&2
   exit 1
fi

echo "Preparing menu..."
apt-get update -y >/dev/null 2>&1
apt-get -qq install dialog git >/dev/null 2>&1

SCRIPT_PATH="/root/NeXt-Server"

GIT_LOCAL_FILES_HEAD=$(git rev-parse --short HEAD)
GIT_LOCAL_FILES_HEAD_LAST_COMMIT=$(git log -1 --date=short --pretty=format:%cd)
source ${SCRIPT_PATH}/configs/versions.cfg
source ${SCRIPT_PATH}/script/functions.sh
source ${SCRIPT_PATH}/script/logs.sh; set_logs
source ${SCRIPT_PATH}/script/prerequisites.sh; prerequisites

chown -R root:root ${SCRIPT_PATH}

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
					source ${SCRIPT_PATH}/install.sh; install
					;;
				2)
					source ${SCRIPT_PATH}/menus/after_install_config_menu.sh; menu_options_after_install
					;;
				3)
					source ${SCRIPT_PATH}/updates/all-services-update.sh; update_all_services
					;;
				4)
					dialog_info "Updating NeXt Server Script"
					source ${SCRIPT_PATH}/update_script.sh; update_script
					dialog_msg "Finished updating NeXt Server Script to Version ${GIT_LOCAL_FILES_HEAD}"
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
