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

function password {

  openssl rand -base64 40 | tr -d / | cut -c -32 | grep -P '(?=^.{8,255}$)(?=^[^\s]*$)(?=.*\d)(?=.*[A-Z])(?=.*[a-z])'
}

setipaddrvars() {

IPADR=$(ip route get 9.9.9.9 | awk '/9.9.9.9/ {print $NF}')
INTERFACE=$(ip route get 9.9.9.9 | head -1 | cut -d' ' -f5)
FQDNIP=$(dig @9.9.9.9 +short ${MYDOMAIN})
WWWIP=$(dig @9.9.9.9 +short www.${MYDOMAIN})
CHECKRDNS=$(dig @9.9.9.9 -x ${IPADR} +short)
}

start_after_install() {
	source ${SCRIPT_PATH}/configuration.sh; show_ssh_key
	read -p "Continue (y/n)?" ANSW
	if [ "$ANSW" = "n" ]; then
		echo "Exit"
		exit 1
	fi

	source ${SCRIPT_PATH}/configuration.sh; show_login_information
	read -p "Continue (y/n)?" ANSW
	if [ "$ANSW" = "n" ]; then
		echo "Exit"
		exit 1
	fi

	source ${SCRIPT_PATH}/configuration.sh; create_private_key
	dialog --backtitle "NeXt Server Installation" --msgbox "Finished after installation configuration" $HEIGHT $WIDTH
}

# Check valid E-Mail
CHECK_E_MAIL="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z])?\$"

CHECK_PASSWORD="^[A-Za-z0-9]*$"

# Check valid Domain
####not perfectly working!!!!
CHECK_DOMAIN="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*.([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z])?\$"

# Date!
CURRENT_DATE=`date +%Y-%m-%d:%H:%M:%S`
