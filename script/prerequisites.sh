#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

prerequisites() {

	trap error_exit ERR

	if [ $(dpkg-query -l | grep build-essential | wc -l) -ne 1 ]; then
		install_packages "build-essential"
	fi

	if [ $(dpkg-query -l | grep dbus | wc -l) -ne 1 ]; then
		install_packages "dbus"
	fi

	if [ $(dpkg-query -l | grep libcrack2 | wc -l) -ne 1 ]; then
		install_packages "libcrack2"
	fi

	if [ $(dpkg-query -l | grep dnsutils | wc -l) -ne 1 ]; then
		install_packages "dnsutils"
	fi

	if [ $(dpkg-query -l | grep netcat | wc -l) -ne 1 ]; then
		install_packages "netcat"
	fi

	if [ $(dpkg-query -l | grep automake | wc -l) -ne 1 ]; then
		install_packages "automake"
	fi

	if [ $(dpkg-query -l | grep autoconf | wc -l) -ne 1 ]; then
		install_packages "autoconf"
	fi

	if [ $(dpkg-query -l | grep gawk | wc -l) -ne 1 ]; then
		install_packages "gawk"
	fi

	if [ $(dpkg-query -l | grep lsb-release | wc -l) -ne 1 ]; then
		install_packages "lsb-release"
	fi
}
