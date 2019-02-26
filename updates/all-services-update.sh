#!/bin/bash

update_all_services() {

trap error_exit ERR

source ${SCRIPT_PATH}/configs/userconfig.cfg

#updating script code base before updating the server!
source ${SCRIPT_PATH}/update_script.sh; update_script

##add update_lets_encrypt

if [[ ${INSTALLED} == '1' ]]; then
  echo "0" | dialog --gauge "Updating package lists..." 10 70 0
  apt-get update >/dev/null 2>&1

  echo "10" | dialog --gauge "Upgrading packages..." 10 70 0
  apt-get -y upgrade >/dev/null 2>&1

  echo "30" | dialog --gauge "Upgrading Debian..." 10 70 0
  apt-get -y dist-upgrade >/dev/null 2>&1

  echo "50" | dialog --gauge "Updating fail2ban..." 10 70 0
  #source ${SCRIPT_PATH}/updates/fail2ban-update.sh; update_fail2ban

  echo "70" | dialog --gauge "Updating Openssh..." 10 70 0
  source ${SCRIPT_PATH}/updates/openssh-update.sh; update_openssh

  dialog_msg "Finished updating all services"
else
	echo "Debian Installer script is not installed, nothing to update..."
fi
}
