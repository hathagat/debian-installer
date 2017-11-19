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

#################################
##  DO NOT MODIFY, JUST DON'T! ##
#################################

install_fail2ban() {

apt-get -y --assume-yes install python >>"${main_log}" 2>>"${err_log}"

mkdir -p ~/sources/${FAIL2BAN_VERSION}/ >>"${main_log}" 2>>"${err_log}"
cd ~/sources/${FAIL2BAN_VERSION}/ >>"${main_log}" 2>>"${err_log}"

wget --no-check-certificate https://codeload.github.com/fail2ban/fail2ban/tar.gz/${FAIL2BAN_VERSION} >>"${main_log}" 2>>"${err_log}"
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

cp ~/configs/jail.local /etc/fail2ban/jail.local

cp files/debian-initd /etc/init.d/fail2ban >>"${main_log}" 2>>"${err_log}"
update-rc.d fail2ban defaults >>"${main_log}" 2>>"${err_log}"
service fail2ban start >>"${main_log}" 2>>"${err_log}"
}

update_fail2ban() {

mkdir -p ~/sources/${FAIL2BAN_VERSION}/ >>"${main_log}" 2>>"${err_log}"
cd ~/sources/${FAIL2BAN_VERSION}/ >>"${main_log}" 2>>"${err_log}"

wget --no-check-certificate https://codeload.github.com/fail2ban/fail2ban/tar.gz/${FAIL2BAN_VERSION} >>"${main_log}" 2>>"${err_log}"
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

cp ~/configs/jail.local /etc/fail2ban/jail.local

cp files/debian-initd /etc/init.d/fail2ban >>"${main_log}" 2>>"${err_log}"
update-rc.d fail2ban defaults >>"${main_log}" 2>>"${err_log}"
service fail2ban start >>"${main_log}" 2>>"${err_log}"

}