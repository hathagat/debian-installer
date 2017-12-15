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

after_install_configuration()
{

SCRIPT_PATH="/root/NeXt-Server"
source ${SCRIPT_PATH}/script/functions.sh
source ${SCRIPT_PATH}/script/menu.sh

HEIGHT=30
WIDTH=60
CHOICE_HEIGHT=10
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

		OPTIONS=(1 "Show SSH Key"
						 2 "Show Login information"
				 		 3 "Create private key"
						 4 "Openssl Options"
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
					show_ssh_key
					;;
				2)
					show_login_information
					;;
				3)
					create_private_key
					;;
				4
					;;
				5)
					bash start.sh
					;;
				6)
					echo "Exit"
					exit 1
					;;
		esac

show_ssh_key()
{
dialog --backtitle "NeXt Server Configuration" --msgbox "Please save the shown SSH privatekey into a textfile on your PC." $HEIGHT $WIDTH
cat ${SCRIPT_PATH}/ssh_privatekey.txt
}

show_login_information()
{
dialog --backtitle "NeXt Server Configuration" --msgbox "Please save the shown SSH privatekey into a textfile on your PC." $HEIGHT $WIDTH
cat ${SCRIPT_PATH}/login_information
}

create_private_key()
{
dialog --backtitle "NeXt Server Configuration" --msgbox "You have to download the latest PuTTYgen (https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) \n
Start the program and click on Conversions- Import key. \n
Now select the Text file, where you saved the ssh_privatekey \n
After entering your SSH Password, you have to switch the paramter from RSA to ED25519 \n
In the last step click on save private key - done!" $HEIGHT $WIDTH
}
}
