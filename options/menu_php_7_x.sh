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

php_7_x_config() {

HEIGHT=30
WIDTH=60
CHOICE_HEIGHT=6
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

	OPTIONS=(1 "Change post_max_size"
				2 "Change upload_max_filesize"
			 	3 "Change memory_limit"
			  	4 "Change max_execution_time"
				5 "Change max_input_vars"
				6 "Back"
			)

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
				CHOICE_HEIGHT=2
				MENU="Change post_max_size"

							post_max_size=$(dialog --clear \
									--backtitle "$BACKTITLE" \
									--inputbox "Please Type your post_max_size value:" \
									$HEIGHT $WIDTH \
									3>&1 1>&2 2>&3 3>&- \
									)
				;;

				2)
				CHOICE_HEIGHT=2
				MENU="Change upload_max_filesize"

							upload_max_filesize=$(dialog --clear \
									--backtitle "$BACKTITLE" \
									--inputbox "Please Type your upload_max_filesize value:" \
									$HEIGHT $WIDTH \
									3>&1 1>&2 2>&3 3>&- \
									)
				;;

				3)
				CHOICE_HEIGHT=2
				MENU="Change memory_limit"

							memory_limit=$(dialog --clear \
									--backtitle "$BACKTITLE" \
									--inputbox "Please Type your memory_limit value:" \
									$HEIGHT $WIDTH \
									3>&1 1>&2 2>&3 3>&- \
									)
				;;

				4)
				CHOICE_HEIGHT=2
				MENU="Change max_execution_time"

							max_execution_time=$(dialog --clear \
									--backtitle "$BACKTITLE" \
									--inputbox "Please Type your max_execution_time value:" \
									$HEIGHT $WIDTH \
									3>&1 1>&2 2>&3 3>&- \
									)
				;;

				5)
				CHOICE_HEIGHT=2
				MENU="Change max_input_vars"

							post_max_size=$(dialog --clear \
									--backtitle "$BACKTITLE" \
									--inputbox "Please Type your max_input_vars value:" \
									$HEIGHT $WIDTH \
									3>&1 1>&2 2>&3 3>&- \
									)
				;;

				6)
				bash ~/NeXt-Server/start.sh
				;;

	
	esac
	# Back to menu
	start.sh
}

