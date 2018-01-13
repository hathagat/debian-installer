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

install_firewall() {

# ipset
if [ $(dpkg-query -l | grep ipset | wc -l) -ne 1 ]; then
	apt-get -y --assume-yes install ipset >>"${main_log}" 2>>"${err_log}"
fi

git clone https://github.com/arno-iptables-firewall/aif.git ${SCRIPT_PATH}/sources/aif -q

# Create folders and copy files
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

# Start Arno-Iptables-Firewall at boot
update-rc.d -f arno-iptables-firewall start 11 S . stop 10 0 6 >>"${main_log}" 2>>"${err_log}"

# Configure firewall.conf
bash /usr/local/share/environment >>"${main_log}" 2>>"${err_log}"

INTERFACE=$(ip route get 9.9.9.9 | head -1 | cut -d' ' -f5)

sed -i "s/^EXT_IF=.*/EXT_IF="${INTERFACE}"/g" /etc/arno-iptables-firewall/firewall.conf
sed -i 's/^EXT_IF_DHCP_IP=.*/EXT_IF_DHCP_IP="0"/g' /etc/arno-iptables-firewall/firewall.conf
sed -i 's/^#FIREWALL_LOG=.*/FIREWALL_LOG="\/var\/log\/firewall.log"/g' /etc/arno-iptables-firewall/firewall.conf
sed -i 's/^DRDOS_PROTECT=.*/DRDOS_PROTECT="1"/g' /etc/arno-iptables-firewall/firewall.conf
sed -i 's/^OPEN_ICMP=.*/OPEN_ICMP="1"/g' /etc/arno-iptables-firewall/firewall.conf
sed -i 's/^#BLOCK_HOSTS_FILE=.*/BLOCK_HOSTS_FILE="\/etc\/arno-iptables-firewall\/blocked-hosts"/g' /etc/arno-iptables-firewall/firewall.conf

if [[ ${USE_MAILSERVER} == '1' ]]; then
	sed -i "s/^OPEN_TCP=.*/OPEN_TCP=\"${SSH_PORT}, 25, 80, 110, 143, 443, 465, 587, 993, 995\"/" /etc/arno-iptables-firewall/firewall.conf
else
	sed -i "s/^OPEN_TCP=.*/OPEN_TCP=\"${SSH_PORT}, 80, 443\"/" /etc/arno-iptables-firewall/firewall.conf
fi

sed -i 's/^OPEN_UDP=.*/OPEN_UDP="143, 587"/' /etc/arno-iptables-firewall/firewall.conf
sed -i 's/^VERBOSE=.*/VERBOSE=1/' /etc/init.d/arno-iptables-firewall

systemctl -q daemon-reload
systemctl -q start arno-iptables-firewall.service

#Fix error with /etc/rc.local
touch /etc/rc.local

# Blacklist some bad guys
mkdir -p ${SCRIPT_PATH}/sources/blacklist
mkdir -p /etc/arno-iptables-firewall/blocklists
sed -i 's/.*IPTABLES_IPSET=.*/IPTABLES_IPSET=1/' /etc/arno-iptables-firewall/firewall.conf
sed -i 's/.*IPTABLES_IPSET_HASHSIZE=.*/IPTABLES_IPSET_HASHSIZE=16384/' /etc/arno-iptables-firewall/firewall.conf
sed -i 's/.*IPTABLES_IPSET_MAXELEM=.*/IPTABLES_IPSET_MAXELEM=120000/' /etc/arno-iptables-firewall/firewall.conf
sed -i 's/.*BLOCK_NETSET_DIR=.*/BLOCK_NETSET_DIR="\/etc\/arno-iptables-firewall\/blocklists"/' /etc/arno-iptables-firewall/firewall.conf

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
