#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

menu_options_addons() {

SCRIPT_PATH="/root/NeXt-Server"

source ${SCRIPT_PATH}/configs/versions.cfg
source ${SCRIPT_PATH}/script/functions.sh
source ${SCRIPT_PATH}/script/logs.sh; set_logs
source ${SCRIPT_PATH}/script/prerequisites.sh; prerequisites

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=9
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

		OPTIONS=(1 "Install TS3 Server"
						 2 "Install Minecraft"
						 3 "Install Nextcloud"
						 4 "Install phpmyadmin"
						 5 "Install Munin (WIP!)"
             6 "Install Wordpress"
						 7 "Deinstall Wordpress"
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
	source ${SCRIPT_PATH}/configs/userconfig.cfg
	source ${SCRIPT_PATH}/addons/teamspeak3.sh; install_teamspeak3
	;;
2)
	source ${SCRIPT_PATH}/configs/userconfig.cfg
	source ${SCRIPT_PATH}/addons/minecraft.sh; install_minecraft
	;;
3)
	source ${SCRIPT_PATH}/configs/userconfig.cfg
	if [[ ${USE_PHP7_1} == '1'  ]] || [[ ${USE_PHP7_2} == '1'  ]]; then
		if [[ ${NXT_IS_INSTALLED} == '1' ]]; then
			dialog --backtitle "NeXt Server Installation" --infobox "Installing nextcloud" $HEIGHT $WIDTH
			source ${SCRIPT_PATH}/addons/nextcloud.sh; install_nextcloud
			dialog --backtitle "NeXt Server Installation" --msgbox "Finished installing nextcloud" $HEIGHT $WIDTH
		else
			echo "You have to install the NeXt Server with the Webserver component to run this Addon!"
		fi
	else
		echo "Nextcloud 13 is only running on PHP 7.1 and 7.2!"
	fi
	;;
4)
	source ${SCRIPT_PATH}/configs/userconfig.cfg
	if [[ ${NXT_IS_INSTALLED} == '1' ]]; then
		dialog --backtitle "NeXt Server Installation" --infobox "Installing phpmyadmin" $HEIGHT $WIDTH
		source ${SCRIPT_PATH}/addons/composer.sh; install_composer
		source ${SCRIPT_PATH}/addons/phpmyadmin.sh; install_phpmyadmin
		dialog --backtitle "NeXt Server Installation" --msgbox "Finished installing phpmyadmin" $HEIGHT $WIDTH
	else
		echo "You have to install the NeXt Server with the Webserver component to run this Addon!"
	fi
	;;
5)
	source ${SCRIPT_PATH}/configs/userconfig.cfg
	if [[ ${NXT_IS_INSTALLED} == '1' ]]; then
		dialog --backtitle "NeXt Server Installation" --infobox "Installing Munin" $HEIGHT $WIDTH
		source ${SCRIPT_PATH}/addons/munin.sh; install_munin
		dialog --backtitle "NeXt Server Installation" --msgbox "Finished installing Munin" $HEIGHT $WIDTH
	else
		echo "You have to install the NeXt Server with the Webserver component to run this Addon!"
	fi
	;;
6)
	source ${SCRIPT_PATH}/configs/userconfig.cfg
	if [[ ${NXT_IS_INSTALLED} == '1' ]]; then
		#dialog --backtitle "NeXt Server Installation" --infobox "Installing Wordpress" $HEIGHT $WIDTH
			source ${SCRIPT_PATH}/configs/userconfig.cfg
			source ${SCRIPT_PATH}/addons/wordpress.sh; install_wordpress
		#dialog --backtitle "NeXt Server Installation" --msgbox "Finished installing Wordpress" $HEIGHT $WIDTH
	else
		echo "You have to install the NeXt Server with the Webserver component to run this Addon!"
	fi
	;;
7)
	source ${SCRIPT_PATH}/configs/userconfig.cfg
	#dialog --backtitle "NeXt Server Installation" --infobox "Installing Wordpress" $HEIGHT $WIDTH
		source ${SCRIPT_PATH}/addons/wordpress.sh; deinstall_wordpress
	#dialog --backtitle "NeXt Server Installation" --msgbox "Finished installing Wordpress" $HEIGHT $WIDTH
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
