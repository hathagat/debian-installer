#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

update_fail2ban() {

mkdir -p ${SCRIPT_PATH}/sources/${FAIL2BAN_VERSION}/ >>"${main_log}" 2>>"${err_log}"
cd ${SCRIPT_PATH}/sources/${FAIL2BAN_VERSION}/ >>"${main_log}" 2>>"${err_log}"

wget --no-check-certificate https://codeload.github.com/fail2ban/fail2ban/tar.gz/${FAIL2BAN_VERSION} --tries=3 >>"${main_log}" 2>>"${err_log}"
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: fail2ban-${FAIL2BAN_VERSION}.tar.gz download failed."
      exit
    fi

tar -xzf ${FAIL2BAN_VERSION} >>"${main_log}" 2>>"${err_log}"
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: fail2ban-${FAIL2BAN_VERSION}.tar.gz is corrupted."
      exit
    fi
rm ${FAIL2BAN_VERSION}

cd fail2ban-${FAIL2BAN_VERSION}
python setup.py -q install >>"${main_log}" 2>>"${err_log}"

cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local >>"${main_log}" 2>>"${err_log}"

cp ${SCRIPT_PATH}/configs/jail.local /etc/fail2ban/jail.local

cp files/debian-initd /etc/init.d/fail2ban >>"${main_log}" 2>>"${err_log}"
update-rc.d fail2ban defaults >>"${main_log}" 2>>"${err_log}"
service fail2ban start >>"${main_log}" 2>>"${err_log}"
}
