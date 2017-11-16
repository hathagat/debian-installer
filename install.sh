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

#################################
##  DO NOT MODIFY, JUST DON'T! ##
#################################

source configs/versions.cfg
source script/logs.sh
source script/prerequisites.sh
source script/checksystem.sh
source script/system.sh
source script/openssl.sh
source script/openssh.sh
source script/fail2ban.sh

#if [[ ${INSTALLATION} = "1" ]]; then
	echo "0" | dialog --gauge "Checking your system..." 10 70 0
	set_logs
	prerequisites
	check_system
	echo "0" | dialog --gauge "Installing System..." 10 70 0
	install_system
	echo "2" | dialog --gauge "Installing OpenSSL..." 10 70 0
	install_openssl
	echo "5" | dialog --gauge "Installing OpenSSH..." 10 70 0
	install_openssh
	echo "10" | dialog --gauge "Installing fail2ban..." 10 70 0
	install_fail2ban
#fi

#if [[ ${UPDATE_INSTALLATION} = "1" ]]; then
#	update_openssl
#	update_openssh
#fi