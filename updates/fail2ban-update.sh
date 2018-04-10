#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

update_fail2ban() {

source ${SCRIPT_PATH}/configs/versions.cfg

LOCAL_FAIL2BAN_VERSION_STRING=$(fail2ban-client --version)
LOCAL_FAIL2BAN_VERSION=$(echo $LOCAL_FAIL2BAN_VERSION_STRING | cut -c10-16)

if [[ ${LOCAL_FAIL2BAN_VERSION} != ${FAIL2BAN_VERSION} ]]; then
  install_packages "python"

  mkdir -p ${SCRIPT_PATH}/sources/${FAIL2BAN_VERSION}/ >>"${main_log}" 2>>"${err_log}"
  cd ${SCRIPT_PATH}/sources/${FAIL2BAN_VERSION}/ >>"${main_log}" 2>>"${err_log}"

  wget_tar "https://codeload.github.com/fail2ban/fail2ban/tar.gz/${FAIL2BAN_VERSION}"
  tar_file "${FAIL2BAN_VERSION}"
  cd fail2ban-${FAIL2BAN_VERSION}

  python setup.py -q install >>"${main_log}" 2>>"${err_log}"

  cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local >>"${main_log}" 2>>"${err_log}"
  cp ${SCRIPT_PATH}/configs/fail2ban/jail.local /etc/fail2ban/jail.local
  cp ${SCRIPT_PATH}/configs/fail2ban/webserver-w00tw00t.conf /etc/fail2ban/filter.d/webserver-w00tw00t.conf

  cp files/debian-initd /etc/init.d/fail2ban >>"${main_log}" 2>>"${err_log}"
  update-rc.d fail2ban defaults >>"${main_log}" 2>>"${err_log}"
  service fail2ban start >>"${main_log}" 2>>"${err_log}"

  rm -R ${SCRIPT_PATH}/sources/${FAIL2BAN_VERSION}
else
	dialog_info "No fail2ban Update needed! Local fail2ban Version: ${LOCAL_FAIL2BAN_VERSION}. Version to be installed: ${FAIL2BAN_VERSION}"
fi
}
