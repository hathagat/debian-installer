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

install_teamspeak3() {

HEIGHT=15
WIDTH=60
dialog --backtitle "Addon-Installation" --infobox "Installing Teamspeak 3..." $HEIGHT $WIDTH

DEBIAN_FRONTEND=noninteractive apt-get -y install sudo >>"${main_log}" 2>>"${err_log}"

adduser ts3user --gecos "" --no-create-home --disabled-password >>"${main_log}" 2>>"${err_log}"
mkdir -p /usr/local/ts3user >>"${main_log}" 2>>"${err_log}"
chown ts3user /usr/local/ts3user >>"${main_log}" 2>>"${err_log}"

cd /usr/local/ts3user >>"${main_log}" 2>>"${err_log}"
wget -q http://dl.4players.de/ts/releases/${TEAMSPEAK_VERSION}/teamspeak3-server_linux_amd64-${TEAMSPEAK_VERSION}.tar.bz2 >>"${main_log}" 2>>"${err_log}"
tar -xjf teamspeak3-server_linux*.tar.bz2 >>"${main_log}" 2>>"${err_log}" >>"${main_log}" 2>>"${err_log}"
mkdir -p /usr/local/ts3user/ts3server/ >>"${main_log}" 2>>"${err_log}"
cp -r -u /usr/local/ts3user/teamspeak3-server_linux_amd64/* /usr/local/ts3user/ts3server/ >>"${main_log}" 2>>"${err_log}"
rm -r /usr/local/ts3user/teamspeak3-server_linux_amd64/ >>"${main_log}" 2>>"${err_log}"

chown -R ts3user /usr/local/ts3user/ts3server >>"${main_log}" 2>>"${err_log}"

touch ${SCRIPT_PATH}/ts3serverdata.txt
timeout 10 sudo -u  ts3user /usr/local/ts3user/ts3server/ts3server_minimal_runscript.sh > ${SCRIPT_PATH}/ts3serverdata.txt

echo "#! /bin/sh
### BEGIN INIT INFO
# Provides:         ts3server
# Required-Start: 	"'$local_fs $network'"
# Required-Stop:	"'$local_fs $network'"
# Default-Start: 	2 3 4 5
# Default-Stop: 	0 1 6
# Description:      TS 3 Server
### END INIT INFO

case "'"$1"'" in
start)
echo "'"Starte Teamspeak 3 Server ... "'"
su ts3user -c "'"/usr/local/ts3user/ts3server/ts3server_startscript.sh start"'"
;;
stop)
echo "'"Beende Teamspeak 3 Server ..."'"
su ts3user -c "'"/usr/local/ts3user/ts3server/ts3server_startscript.sh stop"'"
;;
*)
echo "'"Sie können folgende Befehle nutzen: TS3 starten: /etc/init.d/ts3server start TS3 stoppen: /etc/init.d/ts3server stop"'" > /usr/local/ts3user/ts3server/ts3befehle.txt
exit 1
;;
esac
exit 0" >> /etc/init.d/ts3server

chmod 755 /etc/init.d/ts3server >>"${main_log}" 2>>"${err_log}"
update-rc.d ts3server defaults >>"${main_log}" 2>>"${err_log}"
/etc/init.d/ts3server start >>"${main_log}" 2>>"${err_log}"

TS3_PORTS_TCP="2008, 10011, 30033, 41144"
TS3_PORTS_UDP="2010, 9987"

sed -i "/\<$TS3_PORTS_TCP\>/ "\!"s/^OPEN_TCP=\"/&$TS3_PORTS_TCP, /" /etc/arno-iptables-firewall/firewall.conf >>"${main_log}" 2>>"${err_log}"
sed -i "/\<$TS3_PORTS_UDP\>/ "\!"s/^OPEN_UDP=\"/&$TS3_PORTS_UDP, /" /etc/arno-iptables-firewall/firewall.conf >>"${main_log}" 2>>"${err_log}"
sed -i '1171s/, "/"/' /etc/arno-iptables-firewall/firewall.conf

systemctl force-reload arno-iptables-firewall.service >>"${main_log}" 2>>"${err_log}"

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "TS3 Server Login:" >> ${SCRIPT_PATH}/login_information
echo "Look at: ts3serverdata.txt in the NeXt-Server Folder" >> ${SCRIPT_PATH}/login_information
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "TS3 Server commands:" >> ${SCRIPT_PATH}/login_information
echo "/etc/init.d/ts3server start and /etc/init.d/ts3server stop" >> ${SCRIPT_PATH}/login_information
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information

dialog --backtitle "Addon-Installation" --infobox "Teamspeak 3 Installation finished! Credentials: ${SCRIPT_PATH}/login_information" $HEIGHT $WIDTH
}
