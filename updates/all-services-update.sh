#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

update_all_services() {

source ${SCRIPT_PATH}/configs/userconfig.cfg

#updating script code base before updating the server!
source ${SCRIPT_PATH}/update_script.sh; update_script

if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
  echo "0" | dialog --gauge "Updating package lists..." 10 70 0
  apt-get update >/dev/null 2>&1

  echo "5" | dialog --gauge "Upgrading packages..." 10 70 0
  apt-get -y upgrade >/dev/null 2>&1

  echo "8" | dialog --gauge "Upgrading Debian..." 10 70 0
  apt-get -y dist-upgrade >/dev/null 2>&1

  echo "12" | dialog --gauge "Updating fail2ban..." 10 70 0
  #source ${SCRIPT_PATH}/updates/fail2ban-update.sh; update_fail2ban

  echo "15" | dialog --gauge "Updating firewall..." 10 70 0
  source ${SCRIPT_PATH}/updates/firewall-update.sh; update_firewall

  echo "25" | dialog --gauge "Updating Openssh..." 10 70 0
  source ${SCRIPT_PATH}/updates/openssh-update.sh; update_openssh

  echo "30" | dialog --gauge "Updating Openssl..." 10 70 0
  source ${SCRIPT_PATH}/updates/openssl-update.sh; update_openssl

	echo "60" | dialog --gauge "Updating Nginx..." 10 70 0
	#source ${SCRIPT_PATH}/updates/nginx-update.sh; update_nginx

  if [[ ${NXT_IS_INSTALLED_MAILSERVER} = "1" ]]; then
    echo "Here will be updates for the mailserver later"
  fi

  dialog_msg "Finished updating all services"
else
	echo "The NeXt Server Script is not installed, nothing to update..."
fi
}
