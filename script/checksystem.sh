#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script! 
#-------------------------------------------------------------------------------------------------------------

check_system() {

	if [ $USER != 'root' ]; then
        echo " Please run the script as root"
		exit 1
	fi

	if [ $(lsb_release -is) != 'Debian' ] && [ $(lsb_release -is) != 'Ubuntu' ]; then
		echo "The script only works on Ubuntu 16.04 Xenial and Debian 9.x"
		exit 1
	fi

	if [ $(lsb_release -cs) != 'xenial' ] && [ $(lsb_release -cs) != 'stretch' ]; then
		echo "The script only works on Ubuntu 16.04 Xenial and Debian 9.x"
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

	FREE=`df -k --output=avail "$PWD" | tail -n1`
	if [[ $FREE -lt 8388608 ]]; then
		echo "This script needs at least 8 GB free disk space"
		exit 1
	fi

	if [ $(dpkg-query -l | grep dmidecode | wc -l) -ne 1 ]; then
    	echo "This script does not support the virtualization technology!"
		exit 1
	fi

	if [ "$(dmidecode -s system-product-name)" == 'Bochs' ] || [ "$(dmidecode -s system-product-name)" == 'KVM' ] || [ "$(dmidecode -s system-product-name)" == 'All Series' ] || [ "$(dmidecode -s system-product-name)" == 'OpenStack Nova' ] || [ "$(dmidecode -s system-product-name)" == 'Standard' ]; then
		echo > /dev/null
	else
		if [ $(dpkg-query -l | grep facter | wc -l) -ne 1 ]; then
			apt-get -y --assume-yes install facter >>"${main_log}" 2>>"${err_log}"
		fi

		if	[ "$(facter virtual)" == 'physical' ] || [ "$(facter virtual)" == 'kvm' ]; then
 		echo > /dev/null
		else
	        echo "This script does not support the virtualization technology ($(dmidecode -s system-product-name))"
			exit 1
       fi
	fi
}
