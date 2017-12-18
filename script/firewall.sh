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

menu_options_firewall() {

HEIGHT=30
WIDTH=60
CHOICE_HEIGHT=6
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

	OPTIONS=(1 "Install Firewall"
			 		2 "Update Firewall (not working yet)"
			 		3 "Open TCP Port"
			 		4 "Open UDP Port"
			 		5 "Back"
			 		6 "Exit")

	CHOICE=$(dialog --clear \
					--nocancel \
					--no-cancel \
					--backtitle "$BACKTITLE" \
					--title "$TITLE" \
					--menu "$MENU" \
					$HEIGHT $WIDTH $CHOICE_HEIGHT \
					"${OPTIONS[@]}" \
					2>&1 >/dev/tty)

	clear
	case $CHOICE in
			1)
				dialog --backtitle "NeXt Server Installation" --infobox "Installing Firewall" $HEIGHT $WIDTH
				source ${SCRIPT_PATH}/script/logs.sh; set_logs
				source ${SCRIPT_PATH}/script/prerequisites.sh; prerequisites
				install_firewall
				dialog --backtitle "NeXt Server Installation" --msgbox "Finished installing Firewall" $HEIGHT $WIDTH
				;;
			2)
				dialog --backtitle "NeXt Server Installation" --infobox "Updating Firewall" $HEIGHT $WIDTH
				source ${SCRIPT_PATH}/script/logs.sh; set_logs
				source ${SCRIPT_PATH}/script/prerequisites.sh; prerequisites
				update_firewall
				dialog --backtitle "NeXt Server Installation" --msgbox "Finished updating Firewall" $HEIGHT $WIDTH
				;;
			3)
			while true
					do
						CHOOSE_TCP_PORT=$(dialog --clear \
							--backtitle "$BACKTITLE" \
							--inputbox "Enter your TCP Port (only max. 3 numbers!):" \
							$HEIGHT $WIDTH \
							3>&1 1>&2 2>&3 3>&- \
							)
						if [[ ${CHOOSE_TCP_PORT} =~ ^-?[0-9]+$ ]]; then
								TCP_PORT="$CHOOSE_TCP_PORT"
								sed -i "/\<$TCP_PORT\>/ "\!"s/^OPEN_TCP=\"/&$TCP_PORT, /" /etc/arno-iptables-firewall/firewall.conf
								systemctl force-reload arno-iptables-firewall.service
								dialog --backtitle "NeXt Server Installation Configuration" --msgbox "You are done. The new TCP Port ${TCP_PORT} is opened!" $HEIGHT $WIDTH
								break
						fi
					done
				;;
			4)
			while true
				do
					CHOOSE_UDP_PORT=$(dialog --clear \
						--backtitle "$BACKTITLE" \
						--inputbox "Enter your UDP Port (only max. 3 numbers!):" \
						$HEIGHT $WIDTH \
						3>&1 1>&2 2>&3 3>&- \
						)
					if [[ ${CHOOSE_UDP_PORT} =~ ^-?[0-9]+$ ]]; then
							UDP_PORT="$CHOOSE_UDP_PORT"
							sed -i "/\<$UDP_PORT\>/ "\!"s/^OPEN_UDP=\"/&$UDP_PORT, /" /etc/arno-iptables-firewall/firewall.conf
							systemctl force-reload arno-iptables-firewall.service
							dialog --backtitle "NeXt Server Installation Configuration" --msgbox "You are done. The new UDP Port ${UDP_PORT} is opened!" $HEIGHT $WIDTH
							break
					fi
				done
				;;
			5)
				bash ${SCRIPT_PATH}/start.sh;
				;;
			6)
				echo "Exit"
				exit 1
				;;
	esac
}

install_firewall() {

if [ $(dpkg-query -l | grep ipset | wc -l) -ne 1 ]; then
	apt-get -y --assume-yes install ipset >>"${main_log}" 2>>"${err_log}"
fi

mkdir -p ${SCRIPT_PATH}/sources/aif
git clone https://github.com/arno-iptables-firewall/aif.git ${SCRIPT_PATH}/sources/aif -q
cd ${SCRIPT_PATH}/sources/aif

mkdir -p /usr/local/share/arno-iptables-firewall/plugins
mkdir -p /usr/local/share/man/man1
mkdir -p /usr/local/share/man/man8
mkdir -p /usr/local/share/doc/arno-iptables-firewall
mkdir -p /etc/arno-iptables-firewall/plugins
mkdir -p /etc/arno-iptables-firewall/conf.d

cp bin/arno-iptables-firewall /usr/local/sbin/
cp bin/arno-fwfilter /usr/local/bin/
cp -R share/arno-iptables-firewall/* /usr/local/share/arno-iptables-firewall/

ln -s /usr/local/share/arno-iptables-firewall/plugins/traffic-accounting-show /usr/local/sbin/traffic-accounting-show

gzip -c share/man/man1/arno-fwfilter.1 >/usr/local/share/man/man1/arno-fwfilter.1.gz >>"${main_log}" 2>>"${err_log}"
gzip -c share/man/man8/arno-iptables-firewall.8 >/usr/local/share/man/man8/arno-iptables-firewall.8.gz >>"${main_log}" 2>>"${err_log}"

cp README /usr/local/share/doc/arno-iptables-firewall/
cp etc/init.d/arno-iptables-firewall /etc/init.d/
if [ -d "/usr/lib/systemd/system/" ]; then
  cp lib/systemd/system/arno-iptables-firewall.service /usr/lib/systemd/system/
fi

cp etc/arno-iptables-firewall/firewall.conf /etc/arno-iptables-firewall/
cp etc/arno-iptables-firewall/custom-rules /etc/arno-iptables-firewall/
cp -R etc/arno-iptables-firewall/plugins/ /etc/arno-iptables-firewall/
cp share/arno-iptables-firewall/environment /usr/local/share/

chmod +x /usr/local/sbin/arno-iptables-firewall
chown 0:0 /etc/arno-iptables-firewall/firewall.conf
chown 0:0 /etc/arno-iptables-firewall/custom-rules
chmod +x /usr/local/share/environment

update-rc.d -f arno-iptables-firewall start 11 S . stop 10 0 6 >>"${main_log}" 2>>"${err_log}"

bash /usr/local/share/environment >>"${main_log}" 2>>"${err_log}"

cp ${SCRIPT_PATH}/configs/arno-iptables-firewall/firewall.conf /etc/arno-iptables-firewall/firewall.conf
cp ${SCRIPT_PATH}/configs/arno-iptables-firewall/arno-iptables-firewall /etc/init.d/arno-iptables-firewall

sed -i "s/^EXT_IF=.*/EXT_IF="${INTERFACE}"/g" /etc/arno-iptables-firewall/firewall.conf
sed -i "s/^OPEN_TCP=.*/OPEN_TCP=\"${SSH_PORT}, \"/" /etc/arno-iptables-firewall/firewall.conf

systemctl -q daemon-reload
systemctl -q start arno-iptables-firewall.service

#Fix error with /etc/rc.local
touch /etc/rc.local

# Blacklist some bad guys
mkdir -p ${SCRIPT_PATH}/sources/blacklist
mkdir -p /etc/arno-iptables-firewall/blocklists

cat > /etc/cron.daily/blocked-hosts <<END
#!/bin/bash
BLACKLIST_DIR="${SCRIPT_PATH}/sources/blacklist"
BLACKLIST="/etc/arno-iptables-firewall/blocklists/blocklist.netset"
BLACKLIST_TEMP="\$BLACKLIST_DIR/blacklist"
LIST=(
"https://www.projecthoneypot.org/list_of_ips.php?t=d&rss=1"
"https://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=1.1.1.1"
"https://www.maxmind.com/en/high-risk-ip-sample-list"
"https://danger.rulez.sk/projects/bruteforceblocker/blist.php"
"https://rules.emergingthreats.net/blockrules/compromised-ips.txt"
"https://www.spamhaus.org/drop/drop.lasso"
"http://cinsscore.com/list/ci-badguys.txt"
"https://www.openbl.org/lists/base.txt"
"https://www.autoshun.org/files/shunlist.csv"
"https://lists.blocklist.de/lists/all.txt"
"https://blocklist.greensnow.co/greensnow.txt"
"https://www.stopforumspam.com/downloads/toxic_ip_cidr.txt"
"https://myip.ms/files/blacklist/csf/latest_blacklist.txt"
"https://www.team-cymru.org/Services/Bogons/fullbogons-ipv4.txt"
"https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt"
)
for i in "\${LIST[@]}"
do
    wget -T 10 -t 2 --no-check-certificate -O - \$i | grep -Po '(?:\d{1,3}\.){3}\d{1,3}(?:/\d{1,2})?' >> \$BLACKLIST_TEMP
done
sort \$BLACKLIST_TEMP -n | uniq > \$BLACKLIST
cp \$BLACKLIST_TEMP \${BLACKLIST_DIR}/blacklist\_\$(date '+%d.%m.%Y_%T' | tr -d :) && rm \$BLACKLIST_TEMP
/etc/init.d/arno-iptables-firewall force-reload
END
chmod +x /etc/cron.daily/blocked-hosts

if [[ ${USE_PHP7_1} == '1' ]]; then
	systemctl -q restart {nginx,php7.1-fpm}
fi

if [[ ${USE_PHP7_2} == '1' ]]; then
	systemctl -q restart {nginx,php7.2-fpm}
fi
}

update_firewall() {
	apt-get update
}
