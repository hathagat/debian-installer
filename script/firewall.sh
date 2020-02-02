#!/bin/bash

install_firewall() {
trap error_exit ERR

cd ${SCRIPT_PATH}
install_packages "ipset"
install_packages "arno-iptables-firewall"

touch /etc/rc.local
touch /etc/arno-iptables-firewall/blocked-hosts
mkdir -p /etc/arno-iptables-firewall/blocklists
mkdir -p /etc/arno-iptables-firewall/old_blocklists

# TCP: HTTP, HTTPS, SSH
# UDP: -
sed -i "s/^OPEN_TCP=.*/OPEN_TCP=\"80, 443, ${SSH_PORT}\"/" /etc/arno-iptables-firewall/conf.d/00debconf.conf
sed -i 's/^OPEN_UDP=.*/OPEN_UDP=""/' /etc/arno-iptables-firewall/conf.d/00debconf.conf
sed -i "s/^EXT_IF=.*/EXT_IF="${INTERFACE}"/g" /etc/arno-iptables-firewall/conf.d/00debconf.conf
sed -i 's/^EXT_IF_DHCP_IP=.*/EXT_IF_DHCP_IP=0/g' /etc/arno-iptables-firewall/conf.d/00debconf.conf

echo "DRDOS_PROTECT=1" >> /etc/arno-iptables-firewall/conf.d/00debconf.conf
echo "IPTABLES_IPSET=1" >> /etc/arno-iptables-firewall/conf.d/00debconf.conf
echo "IPTABLES_IPSET_HASHSIZE=16384" >> /etc/arno-iptables-firewall/conf.d/00debconf.conf
echo "IPTABLES_IPSET_MAXELEM=120000" >> /etc/arno-iptables-firewall/conf.d/00debconf.conf

cat > /etc/cron.daily/blocklist <<END
#!/bin/bash

BLACKLIST_DIR="/etc/arno-iptables-firewall/old_blocklists"
BLACKLIST="/etc/arno-iptables-firewall/blocklists/blocklist.netset"
BLACKLIST_TEMP="\$BLACKLIST_DIR/blacklist"
LIST=(
"https://www.projecthoneypot.org/list_of_ips.php?t=d&rss=1"
"https://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=1.1.1.1"
"https://www.maxmind.com/en/high-risk-ip-sample-list"
"http://danger.rulez.sk/projects/bruteforceblocker/blist.php"
"https://rules.emergingthreats.net/blockrules/compromised-ips.txt"
"https://www.spamhaus.org/drop/drop.lasso"
"http://cinsscore.com/list/ci-badguys.txt"
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

chmod +x /etc/cron.daily/blocklist
bash /etc/cron.daily/blocklist >/dev/null 2>&1

systemctl -q restart arno-iptables-firewall
}
