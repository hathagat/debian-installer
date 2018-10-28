#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_fail2ban() {

install_packages "python" >>"${main_log}" 2>>"${err_log}"

mkdir -p ${SCRIPT_PATH}/sources/${FAIL2BAN_VERSION}/ >>"${main_log}" 2>>"${err_log}"
cd ${SCRIPT_PATH}/sources/${FAIL2BAN_VERSION}/ >>"${main_log}" 2>>"${err_log}"

#wget_tar "https://codeload.github.com/fail2ban/fail2ban/tar.gz/${FAIL2BAN_VERSION}"

wget --tries 42 https://github.com/fail2ban/fail2ban/archive/${FAIL2BAN_VERSION}.tar.gz >>"${main_log}" 2>>"${err_log}"
tar -xzvf ${FAIL2BAN_VERSION}.tar.gz >>"${main_log}" 2>>"${err_log}"
cd fail2ban-${FAIL2BAN_VERSION} >>"${main_log}" 2>>"${err_log}"

python setup.py -q install >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install fail2ban package"

cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local >>"${main_log}" 2>>"${err_log}"
cp ${SCRIPT_PATH}/configs/fail2ban/jail.local /etc/fail2ban/jail.local >>"${main_log}" 2>>"${err_log}"
cp ${SCRIPT_PATH}/configs/fail2ban/webserver-w00tw00t.conf /etc/fail2ban/filter.d/webserver-w00tw00t.conf >>"${main_log}" 2>>"${err_log}"

cp files/debian-initd /etc/init.d/fail2ban >>"${main_log}" 2>>"${err_log}"
update-rc.d fail2ban defaults >>"${main_log}" 2>>"${err_log}"
service fail2ban start >>"${main_log}" 2>>"${err_log}"

#rm -R ${SCRIPT_PATH}/sources/${FAIL2BAN_VERSION}
}
