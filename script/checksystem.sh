#!/bin/bash

check_system() {
	trap error_exit ERR

	[ $(lsb_release -is) != 'Debian' ] && [ $(lsb_release -cs) != 'buster' ] && error_exit "Please run the Script with Debian Buster"

	local LOCAL_KERNEL_VERSION=$(uname -a | awk '/Linux/ {print $(NF-7)}')
	[ $LOCAL_KERNEL_VERSION != ${KERNEL_VERSION} ] && error_exit "Please upgrade your Linux Version ($LOCAL_KERNEL_VERSION) with apt-get update && apt-get dist-upgrade to match the script required Version ${KERNEL_VERSION} + reboot your server!"
    echo
}