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

check_dns() {

server_ip=$(ip route get 9.9.9.9 | awk '/9.9.9.9/ {print $NF}')
sed -i "s/server_ip/$server_ip/g" ${SCRIPT_PATH}/dns_settings.txt
dialog --title "DNS Settings" --textbox ${SCRIPT_PATH}/dns_settings.txt 50 200

BACKTITLE="NeXt Server Installation"
TITLE="NeXt Server Installation"
HEIGHT=15
WIDTH=70

CHOICE_HEIGHT=2
MENU="Have you set the DNS Settings 24-48 hours before running this Script?:"
OPTIONS=(1 "Yes"
		 2 "No")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
				--no-cancel \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
	1)
		;;
	2)
		dialog --backtitle "NeXt Server Installation" --msgbox "Sorry, you have to wait 24 - 48 hours, until the DNS system knows your settings!" $HEIGHT $WIDTH
		exit 1
		;;
esac

if [[ $FQDNIP != $IPADR ]]; then
	echo "${MYDOMAIN} does not resolve to the IP address of your server (${IPADR})"
	exit 1
fi

if [[ $CHECKRDNS != mail.${MYDOMAIN}. ]]; then
	echo "Your reverse DNS does not match the SMTP Banner. Please set your Reverse DNS to $(mail.${MYDOMAIN})"
	exit 1
fi
}
