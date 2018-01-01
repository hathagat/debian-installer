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

update_script() {
SCRIPT_PATH="/root/NeXt-Server"

git remote update
if ! git diff --quiet origin/master; then

  mkdir -p /root/backup_next_server

  ### add more important stuff to backup ###
  if [ -d "${SCRIPT_PATH}/logs/" ]; then
    mkdir -p /root/backup_next_server/logs
    cp ${SCRIPT_PATH}/logs/* /root/backup_next_server/logs/
  fi

  if [ -e ${SCRIPT_PATH}/login_information ]; then
    cp ${SCRIPT_PATH}/login_information /root/backup_next_server/
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

  if [ -e /root/backup_next_server/login_information ]; then
    cp /root/backup_next_server/login_information ${SCRIPT_PATH}/
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
  dialog --backtitle "NeXt Server Installation" --msgbox "The local Version ${GIT_LOCAL_FILES_HEAD} is equal with Github, no update needed!" $HEIGHT $WIDTH
  exit 1
fi
}
