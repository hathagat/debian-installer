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

menu_options_mailserver() {

HEIGHT=30
WIDTH=60
CHOICE_HEIGHT=3
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

	OPTIONS=(1 "Update Mailserver"
			 		 2 "Back"
			     3 "Exit")

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
				dialog --backtitle "NeXt Server Installation" --infobox "Updating Mailserver" $HEIGHT $WIDTH
				apt-get update >/dev/null 2>&1
				apt-get -y upgrade >>"${main_log}" 2>>"${err_log}"
				dialog --backtitle "NeXt Server Installation" --msgbox "Finished updating Mailserver" $HEIGHT $WIDTH
				;;
			2)
				bash ${SCRIPT_PATH}/nxt.sh;
				;;
			3)
				echo "Exit"
				exit 1
				;;
	esac
}
