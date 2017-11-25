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

prerequisites() {
	
	#Get out nfs
	apt-get -y --purge remove nfs-kernel-server nfs-common portmap rpcbind >>"${main_log}" 2>>"${err_log}"
	apt-get update -y >>"${main_log}" 2>>"${err_log}"
	
	if [ $(dpkg-query -l | grep build-essential | wc -l) -ne 1 ]; then
		apt-get -y --assume-yes install build-essential >>"${main_log}" 2>>"${err_log}"
	fi
	
	if [ $(dpkg-query -l | grep libcrack2 | wc -l) -ne 1 ]; then
		apt-get -y --assume-yes install libcrack2 >>"${main_log}" 2>>"${err_log}"
	fi

	if [ $(dpkg-query -l | grep dnsutils | wc -l) -ne 1 ]; then
		apt-get -y --assume-yes install dnsutils >>"${main_log}" 2>>"${err_log}"
	fi

	if [ $(dpkg-query -l | grep netcat | wc -l) -ne 1 ]; then
		apt-get -y --assume-yes install netcat >>"${main_log}" 2>>"${err_log}"
	fi
	
	if [ $(dpkg-query -l | grep automake | wc -l) -ne 1 ]; then
		apt-get -y --assume-yes install automake >>"${main_log}" 2>>"${err_log}"
	fi
	
	if [ $(dpkg-query -l | grep autoconf | wc -l) -ne 1 ]; then
		apt-get -y --assume-yes install autoconf >>"${main_log}" 2>>"${err_log}"
	fi
	
	if [ $(dpkg-query -l | grep gawk | wc -l) -ne 1 ]; then
		apt-get -y --assume-yes install gawk >>"${main_log}" 2>>"${err_log}"
	fi
	
	if [ $(dpkg-query -l | grep lsb-release | wc -l) -ne 1 ]; then
		apt-get -y --assume-yes install lsb-release >>"${main_log}" 2>>"${err_log}"
	fi	
}