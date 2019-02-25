#!/bin/bash

install_fail2ban() {

trap error_exit ERR

if [ $(dpkg-query -l | grep python | wc -l) -ne 1 ]; then
	install_packages "python"
fi

mkdir -p ${SCRIPT_PATH}/sources/${FAIL2BAN_VERSION}/ >>"${main_log}" 2>>"${err_log}"
cd ${SCRIPT_PATH}/sources/${FAIL2BAN_VERSION}/ >>"${main_log}" 2>>"${err_log}"

wget_tar "https://codeload.github.com/fail2ban/fail2ban/tar.gz/${FAIL2BAN_VERSION}"
tar_file "${FAIL2BAN_VERSION}"
cd fail2ban-${FAIL2BAN_VERSION}

python setup.py -q install >>"${main_log}" 2>>"${err_log}"

cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local >>"${main_log}" 2>>"${err_log}"
cp ${SCRIPT_PATH}/configs/fail2ban/jail.local /etc/fail2ban/jail.local

cp files/debian-initd /etc/init.d/fail2ban >>"${main_log}" 2>>"${err_log}"
update-rc.d fail2ban defaults >>"${main_log}" 2>>"${err_log}"
service fail2ban start >>"${main_log}" 2>>"${err_log}"

rm -r ${SCRIPT_PATH}/sources/${FAIL2BAN_VERSION}
}
