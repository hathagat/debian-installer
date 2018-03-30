#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_teamspeak3() {

HEIGHT=40
WIDTH=80
dialog_info "Installing Teamspeak 3..."

install_packages "sudo"

adduser ts3user --gecos "" --no-create-home --disabled-password >>"${main_log}" 2>>"${err_log}"
mkdir -p /usr/local/ts3user >>"${main_log}" 2>>"${err_log}"
chown ts3user /usr/local/ts3user >>"${main_log}" 2>>"${err_log}"

cd /usr/local/ts3user >>"${main_log}" 2>>"${err_log}"
wget_tar "http://dl.4players.de/ts/releases/${TEAMSPEAK_VERSION}/teamspeak3-server_linux_amd64-${TEAMSPEAK_VERSION}.tar.bz2"
tar -xjf teamspeak3-server_linux*.tar.bz2 >>"${main_log}" 2>>"${err_log}" >>"${main_log}" 2>>"${err_log}"
mkdir -p /usr/local/ts3user/ts3server/ >>"${main_log}" 2>>"${err_log}"
cp -r -u /usr/local/ts3user/teamspeak3-server_linux_amd64/* /usr/local/ts3user/ts3server/ >>"${main_log}" 2>>"${err_log}"
rm -r /usr/local/ts3user/teamspeak3-server_linux_amd64/ >>"${main_log}" 2>>"${err_log}"

chown -R ts3user /usr/local/ts3user/ts3server >>"${main_log}" 2>>"${err_log}"

touch ${SCRIPT_PATH}/ts3serverdata.txt
touch /usr/local/ts3user/ts3server/.ts3server_license_accepted
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

echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information.txt
echo "Teamspeak 3" >> ${SCRIPT_PATH}/login_information.txt
echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information.txt
echo "TS3 Server Login = Look at: ts3serverdata.txt in the NeXt-Server Folder" >> ${SCRIPT_PATH}/login_information.txt
echo "TS3 Server commands = /etc/init.d/ts3server start and /etc/init.d/ts3server stop" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt

dialog_msg "Teamspeak 3 Installation finished! Credentials: ${SCRIPT_PATH}/login_information.txt"
}
