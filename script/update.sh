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

update_script() {

git remote update
if ! git diff --quiet origin/master; then

  mkdir -p /root/backup_next_server

  ### add more important stuff to backup ###
  if [ -d "${SCRIPT_PATH}/logs/" ]; then
    mkdir -p /root/backup_next_server/logs
    cp ${SCRIPT_PATH}/logs/* /root/backup_next_server/logs/
  fi

  if [ -e ${SCRIPT_PATH}/login_information.txt ]; then
    cp ${SCRIPT_PATH}/login_information.txt /root/backup_next_server/
  fi

  if [ -e ${SCRIPT_PATH}/ssh_privatekey.txt ]; then
    cp ${SCRIPT_PATH}/ssh_privatekey.txt /root/backup_next_server/
  fi

  if [ -e ${SCRIPT_PATH}/installation_times.txt ]; then
    cp ${SCRIPT_PATH}/installation_times.txt /root/backup_next_server/
  fi

  if [ -e ${SCRIPT_PATH}/configs/userconfig.cfg ]; then
    cp ${SCRIPT_PATH}/configs/userconfig.cfg /root/backup_next_server/
  fi

  if [ -e ${SCRIPT_PATH}/configs/versions.cfg ]; then
    cp ${SCRIPT_PATH}/configs/versions.cfg /root/backup_next_server/
  fi

  if [ -e ${SCRIPT_PATH}/DKIM_KEY_ADD_TO_DNS.txt ]; then
    cp ${SCRIPT_PATH}/DKIM_KEY_ADD_TO_DNS.txt /root/backup_next_server/
  fi

  #reset branch
  cd ${SCRIPT_PATH}
  git fetch >>"${main_log}" 2>>"${err_log}"
  git reset --hard origin/master >>"${main_log}" 2>>"${err_log}"

  #restore backup
  if [ -d "/root/backup_next_server/logs/" ]; then
    cp /root/backup_next_server/logs/* ${SCRIPT_PATH}/logs/
  fi

  if [ -e /root/backup_next_server/login_information.txt ]; then
    cp /root/backup_next_server/login_information.txt ${SCRIPT_PATH}/
  fi

  if [ -e /root/backup_next_server/ssh_privatekey.txt ]; then
    cp /root/backup_next_server/ssh_privatekey.txt ${SCRIPT_PATH}/
  fi

  if [ -e /root/backup_next_server/installation_times.txt ]; then
    cp /root/backup_next_server/installation_times.txt ${SCRIPT_PATH}/
  fi

  if [ -e /root/backup_next_server/userconfig.cfg ]; then
    cp /root/backup_next_server/userconfig.cfg ${SCRIPT_PATH}/configs/
  fi

  if [ -e /root/backup_next_server/versions.cfg ]; then
    cp /root/backup_next_server/versions.cfg ${SCRIPT_PATH}/configs/
  fi

  if [ -e /root/backup_next_server/DKIM_KEY_ADD_TO_DNS.txt ]; then
    cp /root/backup_next_server/DKIM_KEY_ADD_TO_DNS.txt ${SCRIPT_PATH}/
  fi

  if [ -e ${SCRIPT_PATH}/configs/versions.cfg ]; then
    cp ${SCRIPT_PATH}/configs/versions.cfg /root/backup_next_server/
  fi

  rm -R /root/backup_next_server/

  GIT_LOCAL_FILES_HEAD=$(git rev-parse --short HEAD)
else
  GIT_LOCAL_FILES_HEAD=$(git rev-parse --short HEAD)
  dialog_msg "The local Version ${GIT_LOCAL_FILES_HEAD} is equal with Github, no update needed!"
  exit 1
fi
}
