#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

update_openssh() {

source ${SCRIPT_PATH}/configs/versions.cfg

LOCAL_OPENSSH_VERSION=$(ssh -V 2>&1 | awk '/OpenSSH/ {print $(NF-6)}')
OPENSSH_VERSION="OpenSSH_${OPENSSH_VERSION}"

if [[ ${LOCAL_OPENSSH_VERSION} != ${OPENSSH_VERSION} ]]; then
	apt-get update >/dev/null 2>&1
	apt-get -y upgrade >/dev/null 2>&1
fi
}
