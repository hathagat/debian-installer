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
source ${SCRIPT_PATH}/configs/versions.cfg
source ${SCRIPT_PATH}/script/functions.sh
source ${SCRIPT_PATH}/script/logs.sh; set_logs
source ${SCRIPT_PATH}/script/prerequisites.sh; prerequisites

HEIGHT=30
WIDTH=60
CHOICE_HEIGHT=14
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

		OPTIONS=(1 "Install NeXt Server Version: ${GIT_LOCAL_FILES_HEAD}"
						 2 "After Installation configuration"
						 3 "Update all services"
						 4 "Mailserver Options"
				 		 5 "Openssh Options"
						 6 "Openssl Options"
						 7 "Fail2ban Options"
						 8 "Nginx vHost Options"
						 9 "PHP 7.x Options"
						 10 "Lets Encrypt Options"
						 11 "Firewall Options"
						 12 "Update NeXt Server Script"
						 13 "Addon Setup"
						 14 "Exit")

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
					HEIGHT=30
					WIDTH=60
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
										source ${SCRIPT_PATH}/configuration.sh; show_login_information
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
					source ${SCRIPT_PATH}/options/menu_mailserver.sh; menu_options_mailserver
					;;
				5)
					source ${SCRIPT_PATH}/options/menu_openssh.sh; menu_options_openssh
					;;
				6)
					source ${SCRIPT_PATH}/options/menu_openssl.sh; menu_options_openssl
					;;
				7)
					source ${SCRIPT_PATH}/options/menu_fail2ban.sh; menu_options_fail2ban
					;;
				8)
					source ${SCRIPT_PATH}/options/menu_vhost.sh; menu_options_nginx_vhost
					;;
				9)
					source ${SCRIPT_PATH}/options/menu_php_7_x.sh; php_7_x_config
					;;
				10)
					source ${SCRIPT_PATH}/options/menu_lets_encrypt.sh; menu_options_lets_encrypt
					;;
				11)
					source ${SCRIPT_PATH}/options/menu_firewall.sh; menu_options_firewall
					;;
				12)
					dialog --backtitle "NeXt Server Installation" --infobox "Updating NeXt Server Script" $HEIGHT $WIDTH
					source ${SCRIPT_PATH}/update_script.sh; update_script
					dialog --backtitle "NeXt Server Installation" --msgbox "Finished updating NeXt Server Script to Version ${GIT_LOCAL_FILES_HEAD}" $HEIGHT $WIDTH
					bash nxt.sh
					;;
				13)
					source ${SCRIPT_PATH}/options/menu_addons.sh; menu_options_addons
					;;
				14)
					echo "Exit"
					exit 1
					;;
		esac
