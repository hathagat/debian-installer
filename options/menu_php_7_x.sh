#!/bin/bash

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
				bash ~/NeXt-Server/nxt.sh
				;;


	esac
	# Back to menu
	nxt.sh
}
