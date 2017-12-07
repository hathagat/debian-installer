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
SCRIPT_PATH="/root/NeXt-Server"

source ${SCRIPT_PATH}/configs/versions.cfg

#if [[ ${INSTALLATION} = "1" ]]; then
	echo "0" | dialog --gauge "Checking your system..." 10 70 0
	source ${SCRIPT_PATH}/script/logs.sh; set_logs
	source ${SCRIPT_PATH}/script/functions.sh
	source ${SCRIPT_PATH}/script/prerequisites.sh; prerequisites
	source ${SCRIPT_PATH}/script/checksystem.sh; check_system

	echo "0" | dialog --gauge "Installing System..." 10 70 0
	source ${SCRIPT_PATH}/script/system.sh; install_system

	echo "2" | dialog --gauge "Installing OpenSSL..." 10 70 0
	source ${SCRIPT_PATH}/script/openssl.sh; install_openssl

	echo "5" | dialog --gauge "Installing OpenSSH..." 10 70 0
	source ${SCRIPT_PATH}/script/openssh.sh; install_openssh

	echo "10" | dialog --gauge "Installing fail2ban..." 10 70 0
	source ${SCRIPT_PATH}/script/fail2ban.sh; install_fail2ban

	echo "12" | dialog --gauge "Installing Nginx Addons..." 10 70 0
	source ${SCRIPT_PATH}/script/nginx_addons.sh; install_nginx_addons

	echo "15" | dialog --gauge "Installing Nginx..." 10 70 0
	source ${SCRIPT_PATH}/script/nginx.sh; install_nginx

	echo "15" | dialog --gauge "Installing LE..." 10 70 0
	source ${SCRIPT_PATH}/script/lets_encrypt.sh; install_lets_encrypt

	echo "25" | dialog --gauge "Installing Nginx Vhost..." 10 70 0
	source ${SCRIPT_PATH}/script/nginx_vhost.sh; install_nginx_vhost

	echo "25" | dialog --gauge "Installing Firewall..." 10 70 0
	source ${SCRIPT_PATH}/script/firewall.sh; install_firewall
#fi

#if [[ ${UPDATE_INSTALLATION} = "1" ]]; then
#	update_openssl
#	update_openssh
#fi
