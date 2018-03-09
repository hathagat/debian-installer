#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

update_openssh() {

source configs/versions.cfg

LOCAL_OPENSSH_VERSION_STRING=$(ssh -V 2>&1)
LOCAL_OPENSSH_VERSION=$(echo $LOCAL_OPENSSH_VERSION_STRING | cut -c9-13)

if [[ ${LOCAL_OPENSSH_VERSION} != ${OPENSSH_VERSION} ]]; then
	#Im moment Platzhalter, bis wir Openssh selbst kompilieren
	apt-get update >/dev/null 2>&1
	apt-get -y --assume-yes install openssh-server openssh-client libpam-dev
else
	HEIGHT=10
	WIDTH=70
	dialog --backtitle "NeXt Server installation!" --infobox "No Openssh Update needed! Local Openssh Version: ${LOCAL_OPENSSH_VERSION}. Version to be installed: ${OPENSSH_VERSION}" $HEIGHT $WIDTH
	exit 1
fi
}
