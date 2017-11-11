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

check_dns() {

server_ip=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')
sed -i "s/server_ip/$server_ip/g" ~/include/dns_settings.txt
dialog --title "DNS Settings" --textbox ~/dns_settings.txt 50 200

if [[ $FQDNIP != $IPADR ]]; then
	echo "${MYDOMAIN} does not resolve to the IP address of your server (${IPADR})"
	exit 1
fi		
		
if [[ $CHECKRDNS != mail.${MYDOMAIN}. ]]; then
	echo "Your reverse DNS does not match the SMTP Banner. Please set your Reverse DNS to $(mail.${MYDOMAIN})"
	exit 1
fi		

if [[ $MAILIP != $IPADR ]]; then
	echo "mail.${MYDOMAIN} does not resolve to the IP address of your server (${IPADR})"
	exit 1
fi			
}