#!/bin/bash

prerequisites() {

	#Get out nfs
	apt-get -y --purge remove nfs-kernel-server nfs-common portmap rpcbind >>"${main_log}" 2>>"${err_log}"

	if [ $(dpkg-query -l | grep build-essential | wc -l) -ne 1 ]; then
		apt-get -y --assume-yes install build-essential >>"${main_log}" 2>>"${err_log}"
	fi

	if [ $(dpkg-query -l | grep dbus | wc -l) -ne 1 ]; then
		apt-get -y --assume-yes install dbus >>"${main_log}" 2>>"${err_log}"
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
