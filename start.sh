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

clear
echo "NeXt Server"
echo "Preparing menu..."

#-------------dialog
apt-get -qq install dialog >/dev/null 2>&1

SCRIPT_PATH="/root/NeXt-Server"

GIT_LOCAL_FILES_HEAD=$(git rev-parse --short HEAD)
source ${SCRIPT_PATH}/configs/versions.cfg
source ${SCRIPT_PATH}/script/functions.sh

HEIGHT=30
WIDTH=60
CHOICE_HEIGHT=12
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

		OPTIONS=(1 "Install NeXt Server Version: ${GIT_LOCAL_FILES_HEAD}"
						 2 "After Installation configuration"
						 3 "Update all services"
						 4 "Install Standalone Mailserver"
				 		 5 "Openssh Options"
						 6 "Openssl Options"
						 7 "Fail2ban Options"
						 8 "Nginx vHost Options"
						 9 "Lets Encrypt Options"
						 10 "Firewall Settings"
						 11 "Update NeXt Server Script"
			     	 12 "Exit")

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
					CHOICE_HEIGHT=10
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
										source ${SCRIPT_PATH}/configuration.sh; show_ssh_key
										read -p "Continue (y/n)?" ANSW
										if [ "$ANSW" = "n" ]; then
											echo "Exit"
										  exit 1
										fi

										source ${SCRIPT_PATH}/configuration.sh; show_login_information
										read -p "Continue (y/n)?" ANSW
										if [ "$ANSW" = "n" ]; then
											echo "Exit"
											exit 1
										fi

										source ${SCRIPT_PATH}/configuration.sh; create_private_key
										dialog --backtitle "NeXt Server Installation" --msgbox "Finished after installation configuration" $HEIGHT $WIDTH
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
										bash ${SCRIPT_PATH}/start.sh
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
					source ${SCRIPT_PATH}/script/logs.sh; set_logs
					source ${SCRIPT_PATH}/script/prerequisites.sh; prerequisites

					source script/openssh.sh; update_openssh
					source script/openssl.sh; update_openssl
					dialog --backtitle "NeXt Server Installation" --msgbox "Finished updating all services" $HEIGHT $WIDTH
					;;
				4)
				# --- MYDOMAIN ---
				while true
					do
						MYDOMAIN=$(dialog --clear \
						--backtitle "$BACKTITLE" \
						--inputbox "Enter your Domain without http:// (exmaple.org):" \
						$HEIGHT $WIDTH \
						3>&1 1>&2 2>&3 3>&- \
						)
							if [[ "$MYDOMAIN" =~ $CHECK_DOMAIN ]];then
								break
							else
								dialog --title "NeXt Server Confighelper" --msgbox "[ERROR] Should we again practice how a Domain address looks?" $HEIGHT $WIDTH
								dialog --clear
							fi
					done

					dialog --backtitle "NeXt Server Installation" --infobox "Install Standalone Mailserver" $HEIGHT $WIDTH
					source ${SCRIPT_PATH}/script/logs.sh; set_logs
					source ${SCRIPT_PATH}/script/functions.sh
					source ${SCRIPT_PATH}/script/prerequisites.sh; prerequisites
					source ${SCRIPT_PATH}/script/functions.sh; setipaddrvars
					source ${SCRIPT_PATH}/configs/versions.cfg


					source ${SCRIPT_PATH}/script/openssl.sh; install_openssl
					source ${SCRIPT_PATH}/script/mariadb.sh; install_mariadb
					source ${SCRIPT_PATH}/script/lets_encrypt.sh; install_lets_encrypt
					#später 7.1 or 7.2
					#source ${SCRIPT_PATH}/script/php7_1.sh; install_php_7_1
					source ${SCRIPT_PATH}/script/unbound.sh; install_unbound
					source ${SCRIPT_PATH}/script/mailserver.sh; install_mailserver
					source ${SCRIPT_PATH}/script/dovecot.sh; install_dovecot
					source ${SCRIPT_PATH}/script/postfix.sh; install_postfix
					source ${SCRIPT_PATH}/script/rspamd.sh; install_rspamd
					#source ${SCRIPT_PATH}/script/rainloop.sh; install_rainloop


					dialog --backtitle "NeXt Server Installation" --msgbox "Finished installing Standalone Mailserver" $HEIGHT $WIDTH
					;;
				5)
					source script/openssh.sh; menu_options_openssh
					;;
				6)
					source script/openssl.sh; menu_options_openssl
					;;
				7)
					source script/fail2ban.sh; menu_options_fail2ban
					;;
				8)
					source script/nginx_vhost.sh; menu_options_nginx_vhost
					;;
				9)
					source script/lets_encrypt.sh; menu_options_lets_encrypt
					;;
				10)
					source script/firewall.sh; menu_options_firewall
					;;
				11)
					dialog --backtitle "NeXt Server Installation" --infobox "Updating NeXt Server Script" $HEIGHT $WIDTH
					source ${SCRIPT_PATH}/update_script.sh; update_script
					dialog --backtitle "NeXt Server Installation" --msgbox "Finished updating NeXt Server Script to Version ${GIT_LOCAL_FILES_HEAD}" $HEIGHT $WIDTH
					bash start.sh
					;;
				12)
					echo "Exit"
					exit 1
					;;
		esac
