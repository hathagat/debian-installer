#!/bin/bash

prerequisites() {
	trap error_exit ERR

	DEBIAN_FRONTEND=noninteractive apt-get -y --purge remove nfs-kernel-server nfs-common portmap rpcbind >>"${main_log}" 2>>"${err_log}"
    DEBIAN_FRONTEND=noninteractive apt-get -y -qq --allow-unauthenticated update >>"${main_log}" 2>>"${err_log}"

    install_packages "dbus man-db ca-certificates lsb-release dnsutils apt-utils apt-transport-https gnupg2 curl wget nano git"
}
