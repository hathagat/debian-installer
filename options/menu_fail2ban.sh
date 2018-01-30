#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#
	# This program is free software; you can redistribute it and/or modify
    # it under the terms of the GNU General Public License as published by
    # the Free Software Foundation; either version 2 of the License, or
    # (at your option) any later version.

    # This program is distributed in the hope that it will be useful,
    # but WITHOUT ANY WARRANTY; without even the implied warranty of
    # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    # GNU General Public License for more details.

    # You should have received a copy of the GNU General Public License along
    # with this program; if not, write to the Free Software Foundation, Inc.,
    # 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#-------------------------------------------------------------------------------------------------------------

menu_options_fail2ban() {

HEIGHT=30
WIDTH=60
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
				dialog --backtitle "NeXt Server Installation" --infobox "Installing fail2ban" $HEIGHT $WIDTH
				source ${SCRIPT_PATH}/script/fail2ban.sh; install_fail2ban || error_exit
				dialog --backtitle "NeXt Server Installation" --msgbox "Finished installing fail2ban" $HEIGHT $WIDTH
				exit 1
				;;
			2)
			  dialog --backtitle "NeXt Server Installation" --infobox "Updating fail2ban" $HEIGHT $WIDTH
			  source ${SCRIPT_PATH}/script/fail2ban.sh; update_fail2ban || error_exit
				dialog --backtitle "NeXt Server Installation" --msgbox "Finished updating fail2ban" $HEIGHT $WIDTH
				;;
			3)
			  dialog --backtitle "NeXt Server Installation" --infobox "Activating fail2ban jails" $HEIGHT $WIDTH

				#placeholder! functions will be added later
				source ${SCRIPT_PATH}/script/fail2ban.sh; activate_fail2ban_jails || error_exit
				dialog --backtitle "NeXt Server Installation" --msgbox "Finished activating fail2ban jails" $HEIGHT $WIDTH
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