#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

menu_options_firewall() {

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=9
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

	OPTIONS=(1 "Install Firewall"
			 		2 "Update Firewall (not working yet)"
			 		3 "Open TCP Port"
			 		4 "Open UDP Port"
					5 "Close TCP Port"
					6 "Close UDP Port"
					7 "Show open Ports"
			 		8 "Back"
			 		9 "Exit")

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
				dialog --backtitle "NeXt Server Installation" --infobox "Installing Firewall" $HEIGHT $WIDTH
				source ${SCRIPT_PATH}/script/firewall.sh; install_firewall || error_exit
				dialog --backtitle "NeXt Server Installation" --msgbox "Finished installing Firewall" $HEIGHT $WIDTH
				;;
			2)
				dialog --backtitle "NeXt Server Installation" --infobox "Updating Firewall" $HEIGHT $WIDTH
				rm -R ${SCRIPT_PATH}/sources/aif
				rm -R ${SCRIPT_PATH}/sources/blacklist
				source ${SCRIPT_PATH}/script/firewall.sh; update_firewall || error_exit
				dialog --backtitle "NeXt Server Installation" --msgbox "Finished updating Firewall" $HEIGHT $WIDTH
				;;
			3)
			while true
					do
						CHOOSE_TCP_PORT=$(dialog --clear \
							--backtitle "$BACKTITLE" \
							--inputbox "Enter your TCP Port (only max. 3 numbers!):" \
							$HEIGHT $WIDTH \
							3>&1 1>&2 2>&3 3>&- \
							)
						if [[ ${CHOOSE_TCP_PORT} =~ ^-?[0-9]+$ ]]; then
								TCP_PORT="$CHOOSE_TCP_PORT"
								sed -i "/\<$TCP_PORT\>/ "\!"s/^OPEN_TCP=\"/&$TCP_PORT, /" /etc/arno-iptables-firewall/firewall.conf
								systemctl force-reload arno-iptables-firewall.service
								dialog --backtitle "NeXt Server Installation Configuration" --msgbox "You are done. The new TCP Port ${TCP_PORT} is opened!" $HEIGHT $WIDTH
								break
						fi
					done
					source ${SCRIPT_PATH}/options/menu_firewall.sh; menu_options_firewall
				;;
			4)
			while true
				do
					CHOOSE_UDP_PORT=$(dialog --clear \
						--backtitle "$BACKTITLE" \
						--inputbox "Enter your UDP Port (only max. 3 numbers!):" \
						$HEIGHT $WIDTH \
						3>&1 1>&2 2>&3 3>&- \
						)
					if [[ ${CHOOSE_UDP_PORT} =~ ^-?[0-9]+$ ]]; then
							UDP_PORT="$CHOOSE_UDP_PORT"
							sed -i "/\<$UDP_PORT\>/ "\!"s/^OPEN_UDP=\"/&$UDP_PORT, /" /etc/arno-iptables-firewall/firewall.conf
							systemctl force-reload arno-iptables-firewall.service
							dialog --backtitle "NeXt Server Installation Configuration" --msgbox "You are done. The new UDP Port ${UDP_PORT} is opened!" $HEIGHT $WIDTH
							break
					fi
				done
				source ${SCRIPT_PATH}/options/menu_firewall.sh; menu_options_firewall
				;;
			5)
			while true
				do
					CHOOSE_TCP_PORT_CLOSE=$(dialog --clear \
						--backtitle "$BACKTITLE" \
						--inputbox "Enter your TCP Port (only max. 3 numbers!):" \
						$HEIGHT $WIDTH \
						3>&1 1>&2 2>&3 3>&- \
						)
					if [[ ${CHOOSE_TCP_PORT_CLOSE} =~ ^-?[0-9]+$ ]]; then
							TCP_PORT_CLOSE="$CHOOSE_TCP_PORT_CLOSE"
							sed -i "s/$TCP_PORT_CLOSE, //g" /etc/arno-iptables-firewall/firewall.conf
							systemctl force-reload arno-iptables-firewall.service
							dialog --backtitle "NeXt Server Installation Configuration" --msgbox "You are done. The TCP Port ${TCP_PORT_CLOSE} is closed!" $HEIGHT $WIDTH
							break
					fi
				done
				source ${SCRIPT_PATH}/options/menu_firewall.sh; menu_options_firewall
				;;
			6)
			while true
				do
					CHOOSE_UDP_PORT_CLOSE=$(dialog --clear \
						--backtitle "$BACKTITLE" \
						--inputbox "Enter your UDP Port (only max. 3 numbers!):" \
						$HEIGHT $WIDTH \
						3>&1 1>&2 2>&3 3>&- \
						)
					if [[ ${CHOOSE_UDP_PORT_CLOSE} =~ ^-?[0-9]+$ ]]; then
							UDP_PORT_CLOSE="$CHOOSE_UDP_PORT_CLOSE"
							sed -i "s/$UDP_PORT_CLOSE, //g" /etc/arno-iptables-firewall/firewall.conf
							systemctl force-reload arno-iptables-firewall.service
							dialog --backtitle "NeXt Server Installation Configuration" --msgbox "You are done. The UDP Port ${UDP_PORT_CLOSE} is closed!" $HEIGHT $WIDTH
							break
					fi
				done
				source ${SCRIPT_PATH}/options/menu_firewall.sh; menu_options_firewall
				;;
			7)
				source ${SCRIPT_PATH}/service-options/firewall-options.sh; show_open_ports || error_exit
				source ${SCRIPT_PATH}/options/menu_firewall.sh; menu_options_firewall
				;;
			8)
				bash ${SCRIPT_PATH}/nxt.sh;
				;;
			9)
				echo "Exit"
				exit 1
				;;
	esac
}
