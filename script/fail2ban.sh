#!/bin/bash

install_fail2ban() {

apt-get -y --assume-yes install python >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install python package"

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
python setup.py -q install >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install fail2ban package"

cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local >>"${main_log}" 2>>"${err_log}"

cp ${SCRIPT_PATH}/configs/jail.local /etc/fail2ban/jail.local

cp files/debian-initd /etc/init.d/fail2ban >>"${main_log}" 2>>"${err_log}"
update-rc.d fail2ban defaults >>"${main_log}" 2>>"${err_log}"
service fail2ban start >>"${main_log}" 2>>"${err_log}"

rm -R ${SCRIPT_PATH}/sources/${FAIL2BAN_VERSION}
}

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

activate_fail2ban_jails() {
	#placeholder! functions will be added later
	apt-get update >/dev/null 2>&1
}
