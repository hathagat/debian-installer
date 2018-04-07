#!/bin/bash

update_openssh() {

source configs/versions.cfg

LOCAL_OPENSSH_VERSION_STRING=$(ssh -V 2>&1)
LOCAL_OPENSSH_VERSION=$(echo $LOCAL_OPENSSH_VERSION_STRING | cut -c9-13)

if [[ ${LOCAL_OPENSSH_VERSION} != ${OPENSSH_VERSION} ]]; then
	#Im moment Platzhalter, bis wir Openssh selbst kompilieren
	apt-get update >/dev/null 2>&1
	install_packages "openssh-server openssh-client libpam-dev"
else
	HEIGHT=40
	WIDTH=80
	dialog_info "No Openssh Update needed! Local Openssh Version: ${LOCAL_OPENSSH_VERSION}. Version to be installed: ${OPENSSH_VERSION}"
	exit 1
fi
}
