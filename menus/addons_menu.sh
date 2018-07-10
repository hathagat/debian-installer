#!/bin/bash
# Compatible with Debian 10.x Buster
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

menu_options_addons() {

SCRIPT_PATH="/root/NeXt-Server"

source ${SCRIPT_PATH}/configs/versions.cfg
source ${SCRIPT_PATH}/script/functions.sh
source ${SCRIPT_PATH}/script/logs.sh; set_logs
source ${SCRIPT_PATH}/script/prerequisites.sh; prerequisites
source ${SCRIPT_PATH}/configs/userconfig.cfg

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=11
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

		OPTIONS=(1 "Install TS3 Server"
		 				 2 "Deinstall TS3 Server"
						 3 "Install Composer"
						 4 "Install Nextcloud"
						 5 "Deinstall Nextcloud"
						 6 "Install phpmyadmin"
						 7 "Install Munin"
             8 "Install Wordpress"
						 9 "Deinstall Wordpress"
						 10 "Back"
						 11 "Exit")

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
	if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
		dialog_info "Installing Teamspeak 3"
		source ${SCRIPT_PATH}/addons/teamspeak3.sh; install_teamspeak3
		dialog_msg "Finished installing Teamspeak 3! Credentials: ${SCRIPT_PATH}/teamspeak3_login_data.txt"
	else
		echo "You have to install the NeXt Server to run this Addon!"
	fi
	;;
2)
	dialog_info "Deinstalling Teamspeak 3"
		source ${SCRIPT_PATH}/addons/teamspeak3_deinstall.sh; deinstall_teamspeak3
	dialog_msg "Finished Deinstalling Teamspeak 3.\n
	Closed Ports TCP: 2008, 10011, 30033, 41144\n
	UDP: 2010, 9987\n
	If you need them, please reopen them manually!"
	;;
3)
	if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
	dialog_info "Installing Composer"
	source ${SCRIPT_PATH}/addons/composer.sh; install_composer
	dialog_msg "Finished installing Composer"
else
	echo "You have to install the NeXt Server with the Webserver component to run this Addon!"
fi
;;
4)
	if [[ ${USE_PHP7_1} == '1'  ]] || [[ ${USE_PHP7_2} == '1'  ]]; then
		if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
			dialog_info "Installing Nextcloud"
			#source ${SCRIPT_PATH}/menus/nextcloud_menu.sh; menu_options_nextcloud
			source ${SCRIPT_PATH}/addons/nextcloud.sh; install_nextcloud
			dialog --title "Your Nextcloud logininformations" --tab-correct --exit-label "ok" --textbox ${SCRIPT_PATH}/nextcloud_login_data.txt 50 200
		else
			echo "You have to install the NeXt Server with the Webserver component to run this Addon!"
		fi
	else
		echo "Nextcloud 13 is only running on PHP 7.1 and 7.2!"
	fi
	;;
5)
	dialog_info "Deinstalling Nextcloud"
		source ${SCRIPT_PATH}/addons/nextcloud_deinstall.sh; deinstall_nextcloud
	dialog_msg "Finished Deinstalling Nextcloud"
	;;
6)
	if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
		dialog_info "Installing PHPmyadmin"
		source ${SCRIPT_PATH}/addons/composer.sh; install_composer
		source ${SCRIPT_PATH}/addons/phpmyadmin.sh; install_phpmyadmin
		dialog_msg "Finished installing PHPmyadmin"
	else
		echo "You have to install the NeXt Server with the Webserver component to run this Addon!"
	fi
	;;
7)
	if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
		dialog_info "Installing Munin"
		source ${SCRIPT_PATH}/addons/munin.sh; install_munin
		dialog_msg "Finished installing Munin"
	else
		echo "You have to install the NeXt Server with the Webserver component to run this Addon!"
	fi
	;;
8)
	if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
		source ${SCRIPT_PATH}/menus/wordpress_menu.sh; menu_options_wordpress
		source ${SCRIPT_PATH}/addons/wordpress.sh; install_wordpress
		dialog_msg "Visit ${MYDOMAIN}/${WORDPRESS_PATH_NAME} to finish the installation"
	else
		echo "You have to install the NeXt Server with the Webserver component to run this Addon!"
	fi
	;;
9)
	dialog_info "Deinstalling Wordpress"
		source ${SCRIPT_PATH}/addons/wordpress_deinstall.sh; deinstall_wordpress
	dialog_msg "Finished Deinstalling Wordpress"
	;;
10)
  bash ${SCRIPT_PATH}/nxt.sh;
  ;;
11)
	echo "Exit"
	exit 1
	;;
esac
}
