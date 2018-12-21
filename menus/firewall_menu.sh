#!/bin/bash

menu_options_firewall() {

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=7
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

	OPTIONS=(1 "Open TCP Port"
			 		2 "Open UDP Port"
					3 "Close TCP Port"
					4 "Close UDP Port"
					5 "Show open Ports"
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
			while true
					do
						CHOOSE_TCP_PORT=$(dialog --clear \
							--backtitle "$BACKTITLE" \
							--inputbox "Enter your TCP Port (only max. 6 numbers!):" \
							$HEIGHT $WIDTH \
							3>&1 1>&2 2>&3 3>&- \
							)
						if [[ ${CHOOSE_TCP_PORT} =~ ^-?[0-9]+$ ]]; then
								TCP_PORT="$CHOOSE_TCP_PORT"
								if [ ${#TCP_PORT} -ge 7 ]; then
										dialog_msg "Your Input has more than 6 numbers, please try again"
										source ${SCRIPT_PATH}/options/menu_firewall.sh; menu_options_firewall
                else
                    sed -i "/\<$TCP_PORT\>/ "\!"s/^OPEN_TCP=\"/&$TCP_PORT, /" /etc/arno-iptables-firewall/firewall.conf
										systemctl force-reload arno-iptables-firewall.service
										dialog_msg "You are done. The new TCP Port ${TCP_PORT} is opened!"
                fi
								break
						fi
					done
					source ${SCRIPT_PATH}/options/menu_firewall.sh; menu_options_firewall
				;;
			2)
			while true
				do
					CHOOSE_UDP_PORT=$(dialog --clear \
						--backtitle "$BACKTITLE" \
						--inputbox "Enter your UDP Port (only max. 6 numbers!):" \
						$HEIGHT $WIDTH \
						3>&1 1>&2 2>&3 3>&- \
						)
					if [[ ${CHOOSE_UDP_PORT} =~ ^-?[0-9]+$ ]]; then
							UDP_PORT="$CHOOSE_UDP_PORT"
							if [ ${#UDP_PORT} -ge 7 ]; then
									dialog_msg "Your Input has more than 6 numbers, please try again"
									source ${SCRIPT_PATH}/options/menu_firewall.sh; menu_options_firewall
							else
									sed -i "/\<$UDP_PORT\>/ "\!"s/^OPEN_UDP=\"/&$UDP_PORT, /" /etc/arno-iptables-firewall/firewall.conf
									systemctl force-reload arno-iptables-firewall.service
									dialog_msg "You are done. The new UDP Port ${UDP_PORT} is opened!"
							fi
							break
					fi
				done
				source ${SCRIPT_PATH}/options/menu_firewall.sh; menu_options_firewall
				;;
			3)
			while true
				do
					CHOOSE_TCP_PORT_CLOSE=$(dialog --clear \
						--backtitle "$BACKTITLE" \
						--inputbox "Enter your TCP Port (only max. 6 numbers!):" \
						$HEIGHT $WIDTH \
						3>&1 1>&2 2>&3 3>&- \
						)
					if [[ ${CHOOSE_TCP_PORT_CLOSE} =~ ^-?[0-9]+$ ]]; then
							TCP_PORT_CLOSE="$CHOOSE_TCP_PORT_CLOSE"
							if [ ${#TCP_PORT_CLOSE} -ge 7 ]; then
									dialog_msg "Your Input has more than 6 numbers, please try again"
									source ${SCRIPT_PATH}/options/menu_firewall.sh; menu_options_firewall
							else
									sed -i "s/$TCP_PORT_CLOSE, //g" /etc/arno-iptables-firewall/firewall.conf
									systemctl force-reload arno-iptables-firewall.service
									dialog_msg "You are done. The TCP Port ${TCP_PORT_CLOSE} is closed!"
							fi
							break
					fi
				done
				source ${SCRIPT_PATH}/options/menu_firewall.sh; menu_options_firewall
				;;
			4)
			while true
				do
					CHOOSE_UDP_PORT_CLOSE=$(dialog --clear \
						--backtitle "$BACKTITLE" \
						--inputbox "Enter your UDP Port (only max. 6 numbers!):" \
						$HEIGHT $WIDTH \
						3>&1 1>&2 2>&3 3>&- \
						)
					if [[ ${CHOOSE_UDP_PORT_CLOSE} =~ ^-?[0-9]+$ ]]; then
							UDP_PORT_CLOSE="$CHOOSE_UDP_PORT_CLOSE"
							if [ ${#UDP_PORT_CLOSE} -ge 7 ]; then
									dialog_msg "Your Input has more than 6 numbers, please try again"
									source ${SCRIPT_PATH}/options/menu_firewall.sh; menu_options_firewall
							else
									sed -i "s/$UDP_PORT_CLOSE, //g" /etc/arno-iptables-firewall/firewall.conf
									systemctl force-reload arno-iptables-firewall.service
									dialog_msg "You are done. The UDP Port ${UDP_PORT_CLOSE} is closed!"
							fi
							break
					fi
				done
				source ${SCRIPT_PATH}/options/menu_firewall.sh; menu_options_firewall
				;;
			5)
				source ${SCRIPT_PATH}/script/firewall_options.sh; show_open_ports || error_exit
				source ${SCRIPT_PATH}/options/menu_firewall.sh; menu_options_firewall
				;;
			6)
				bash ${SCRIPT_PATH}/nxt.sh
				;;
			7)
				echo "Exit"
				exit 1
				;;
	esac
}
