#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

update_all_services() {

source ${SCRIPT_PATH}/configs/userconfig.cfg  

BACKTITLE="NeXt Server Installation"
TITLE="NeXt Server Installation"
HEIGHT=15
WIDTH=70

CHOICE_HEIGHT=2
MENU="Do you want to update the NeXt Server Code Base before updating all services?:"
OPTIONS=(1 "Yes (recommended)"
		 2 "No")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
				--no-cancel \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
	1)
    dialog_info "Updating NeXt Server Script"
    source ${SCRIPT_PATH}/update_script.sh; update_script
    dialog_msg "Finished updating NeXt Server Script to Version ${GIT_LOCAL_FILES_HEAD}"
		;;
	2)
		dialog_msg "Okay, skipping updating the NeXt Server Code Base and starting the update process!"
		;;
esac

#check if installed, otherwise skip single services
if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
  echo "0" | dialog --gauge "Updating package lists..." 10 70 0
  apt-get update

  echo "5" | dialog --gauge "Upgrading packages..." 10 70 0
  apt-get upgrade

  echo "8" | dialog --gauge "Upgrading Debian / Ubuntu..." 10 70 0
  apt-get dist-upgrade

  echo "12" | dialog --gauge "Updating fail2ban..." 10 70 0
  #source ${SCRIPT_PATH}/updates/fail2ban-update.sh; update_fail2ban

  echo "15" | dialog --gauge "Updating firewall..." 10 70 0
  #source ${SCRIPT_PATH}/updates/firewall-update.sh; update_firewall

  echo "25" | dialog --gauge "Updating Openssh..." 10 70 0
  #source ${SCRIPT_PATH}/updates/openssh-update.sh; update_openssh

  echo "30" | dialog --gauge "Updating Openssl..." 10 70 0
  source ${SCRIPT_PATH}/updates/openssl-update.sh; update_openssl

  if [[ ${NXT_IS_INSTALLED_MAILSERVER} = "1" ]]; then
    echo "Here will be updates for the mailserver later"
  fi

  dialog_msg "Finished updating all services"
else
	echo "The NeXt Server Script is not installed, nothing to update..."
fi
}
