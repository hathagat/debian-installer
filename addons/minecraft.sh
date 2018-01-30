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

install_minecraft() {

CHOICE_HEIGHT=4
MENU="Select Minecraft Java RAM:"
OPTIONS=(1 "1024"
		 2 "2048"
		 3 "4096"
		 4 "6144")
menu
clear
case $CHOICE in
		1)
			MINECRAFT_JAVA_RAM="1024"
			;;
		2)
			MINECRAFT_JAVA_RAM="2048"
			;;
		3)
			MINECRAFT_JAVA_RAM="4096"
			;;
		4)
			MINECRAFT_JAVA_RAM="6144"
			;;
esac

HEIGHT=15
WIDTH=60
dialog --backtitle "Addon-Installation" --infobox "Installing Minecraft..." $HEIGHT $WIDTH

apt-get -y install screen openjdk-8-jre-headless >>"${main_log}" 2>>"${err_log}"

adduser minecraft --gecos "" --no-create-home --disabled-password >>"${main_log}" 2>>"${err_log}"

MINECRAFT_PORTS="25565"
sed -i "/\<$MINECRAFT_PORTS\>/ "\!"s/^OPEN_TCP=\"/&$MINECRAFT_PORTS, /" /etc/arno-iptables-firewall/firewall.conf

systemctl force-reload arno-iptables-firewall.service >>"${main_log}" 2>>"${err_log}"

mkdir -p /usr/local/minecraft/
chown minecraft /usr/local/minecraft/ >>"${main_log}" 2>>"${err_log}"
cd /usr/local/minecraft/
sudo -u  minecraft wget -q https://s3.amazonaws.com/Minecraft.Download/versions/${MINECRAFT_VERSION}/minecraft_server.${MINECRAFT_VERSION}.jar

echo "#!/bin/bash
cd /usr/local/minecraft/
java -Xmx${MINECRAFT_JAVA_RAM}M -Xms${MINECRAFT_JAVA_RAM}M -jar minecraft_server.${MINECRAFT_VERSION}.jar nogui
" >> /usr/local/minecraft/run-minecraft-server.sh

chmod +x run-minecraft-server.sh

sudo chown -c minecraft /usr/local/minecraft/run-minecraft-server.sh
sudo -u  minecraft /usr/local/minecraft/run-minecraft-server.sh >>"${main_log}" 2>>"${err_log}"

sed -i 's|eula=false|eula=true|' /usr/local/minecraft/eula.txt

echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information
echo "Minecraft" >> ${SCRIPT_PATH}/login_information
echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information
echo "Zum starten von Minecraft bitte folgenden Befehl verwenden: screen sudo -u  minecraft /usr/local/minecraft/run-minecraft-server.sh" >> ${SCRIPT_PATH}/login_information
echo "Um die Screen Session zu verlassen: Ctrl + A dann Ctrl + D drücken" >> ${SCRIPT_PATH}/login_information
echo "Zum zurück kehren in die Screen Session: screen -r in der Terminal eingeben" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information

dialog --backtitle "Addon-Installation" --infobox "Minecraft Installation finished! Credentials: ~/addoninformation.txt" $HEIGHT $WIDTH
}
