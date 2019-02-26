#!/bin/bash

update_script() {

git remote update
if ! git diff --quiet origin/master; then

  BACKUP_PATH=${SCRIPT_PATH}/backup
  mkdir -p ${BACKUP_PATH}

  # add important stuff to backup
  if [ -d "${SCRIPT_PATH}/logs/" ]; then
    mkdir -p ${BACKUP_PATH}/logs
    cp ${SCRIPT_PATH}/logs/* ${BACKUP_PATH}/logs/
  fi

  if [ -e ${SCRIPT_PATH}/login_information.txt ]; then
    cp ${SCRIPT_PATH}/login_information.txt ${BACKUP_PATH}
  fi

  if [ -e ${SCRIPT_PATH}/ssh_privatekey.txt ]; then
    cp ${SCRIPT_PATH}/ssh_privatekey.txt ${BACKUP_PATH}
  fi

  if [ -e ${SCRIPT_PATH}/installation_times.txt ]; then
    cp ${SCRIPT_PATH}/installation_times.txt ${BACKUP_PATH}
  fi

  if [ -e ${SCRIPT_PATH}/configs/userconfig.cfg ]; then
    cp ${SCRIPT_PATH}/configs/userconfig.cfg ${BACKUP_PATH}
  fi

  if [ -e ${SCRIPT_PATH}/configs/versions.cfg ]; then
    cp ${SCRIPT_PATH}/configs/versions.cfg ${BACKUP_PATH}
  fi

  if [ -e ${SCRIPT_PATH}/DKIM_KEY_ADD_TO_DNS.txt ]; then
    cp ${SCRIPT_PATH}/DKIM_KEY_ADD_TO_DNS.txt ${BACKUP_PATH}
  fi

  # reset branch
  cd ${SCRIPT_PATH}
  git fetch >>"${main_log}" 2>>"${err_log}"
  git reset --hard origin/master >>"${main_log}" 2>>"${err_log}"

  # restore backup
  if [ -d "${BACKUP_PATH}/logs/" ]; then
    cp ${BACKUP_PATH}/logs/* ${SCRIPT_PATH}/logs/
  fi

  if [ -e ${BACKUP_PATH}/login_information.txt ]; then
    cp ${BACKUP_PATH}/login_information.txt ${SCRIPT_PATH}/
  fi

  if [ -e ${BACKUP_PATH}/ssh_privatekey.txt ]; then
    cp ${BACKUP_PATH}/ssh_privatekey.txt ${SCRIPT_PATH}/
  fi

  if [ -e ${BACKUP_PATH}/installation_times.txt ]; then
    cp ${BACKUP_PATH}/installation_times.txt ${SCRIPT_PATH}/
  fi

  if [ -e ${BACKUP_PATH}/userconfig.cfg ]; then
    cp ${BACKUP_PATH}/userconfig.cfg ${SCRIPT_PATH}/configs/
  fi

  if [ -e ${BACKUP_PATH}/versions.cfg ]; then
    cp ${BACKUP_PATH}/versions.cfg ${SCRIPT_PATH}/configs/
  fi

  if [ -e ${BACKUP_PATH}/DKIM_KEY_ADD_TO_DNS.txt ]; then
    cp ${BACKUP_PATH}/DKIM_KEY_ADD_TO_DNS.txt ${SCRIPT_PATH}/
  fi

  rm -r ${BACKUP_PATH}

  GIT_LOCAL_FILES_HEAD=$(git rev-parse --short HEAD)
else
  GIT_LOCAL_FILES_HEAD=$(git rev-parse --short HEAD)
  dialog_msg "The local Version ${GIT_LOCAL_FILES_HEAD} is equal with Github, no update needed!"
  exit 1
fi
}
