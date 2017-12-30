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

check_system() {

	if [ $USER != 'root' ]; then
        echo " Please run the script as root"
		exit 1
	fi

	if [ $(lsb_release -is) != 'Debian' ] && [ $(lsb_release -is) != 'Ubuntu' ]; then
		echo "The script for now works only on $(textb Ubuntu) $(textb 16.04 Xenial) and $(textb Debian) $(textb 9.x)"
		exit 1
	fi

	if [ $(lsb_release -cs) != 'xenial' ] && [ $(lsb_release -cs) != 'stretch' ]; then
		echo "The script for now works only on $(textb Ubuntu) $(textb 16.04 Xenial) and $(textb Debian) $(textb 9.x)"
		exit 1
	fi

	if [ $(lsb_release -cs) == 'xenial' ] && [ $(lsb_release -is) == 'Ubuntu' ]; then
		DISTOS="UBUNTU"
	fi

	if [ $(lsb_release -cs) == 'stretch' ] && [ $(lsb_release -is) == 'Debian' ]; then
		DISTOS="DEBIAN"
	fi

	if [ $(grep MemTotal /proc/meminfo | awk '{print $2}') -lt 1000000 ]; then
		echo "This script needs at least ~1000MB of memory"
	fi

	#FREE=`df -k --output=avail "$PWD" | tail -n1`
	#if [[ $FREE -lt 8388608 ]]; then
		#echo "This script needs at least 8 GB free disk space"
	#	exit 1
	#fi

	if [ $(dpkg-query -l | grep dmidecode | wc -l) -ne 1 ]; then
    	echo "This script does not support the virtualization technology!"
		exit 1
	fi

#	if [ "$(dmidecode -s system-product-name)" == 'Bochs' ] || [ "$(dmidecode -s system-product-name)" == 'KVM' ] || [ "$(dmidecode -s system-product-name)" == 'All Series' ] || [ "$(dmidecode -s system-product-name)" == 'OpenStack Nova' ] || [ "$(dmidecode -s system-product-name)" == 'Standard' ]; then
#		echo > /dev/null
#	else
#		if [ $(dpkg-query -l | grep facter | wc -l) -ne 1 ]; then
#			apt-get -y --assume-yes install facter >>"${main_log}" 2>>"${err_log}"
#		fi
#
#		if	[ "$(facter virtual)" == 'physical' ] || [ "$(facter virtual)" == 'kvm' ]; then
#			echo > /dev/null
#		else
#	        echo "This script does not support the virtualization technology ($(dmidecode -s system-product-name))"
#			exit 1
#       fi
#	fi
}
