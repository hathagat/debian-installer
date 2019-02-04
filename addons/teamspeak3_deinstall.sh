#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

deinstall_teamspeak3() {

trap error_exit ERR

/etc/init.d/ts3server stop
deluser ts3user
rm -rf /usr/local/ts3user
rm ${SCRIPT_PATH}/teamspeak3_login_data.txt
rm /etc/init.d/ts3server

sed -i "s/2008, //g" /etc/arno-iptables-firewall/firewall.conf
sed -i "s/10011, //g" /etc/arno-iptables-firewall/firewall.conf
sed -i "s/30033, //g" /etc/arno-iptables-firewall/firewall.conf
sed -i "s/41144, //g" /etc/arno-iptables-firewall/firewall.conf

sed -i "s/2010, //g" /etc/arno-iptables-firewall/firewall.conf
sed -i "s/9987, //g" /etc/arno-iptables-firewall/firewall.conf

systemctl force-reload arno-iptables-firewall.service >>"${main_log}" 2>>"${err_log}"

sed -i 's/TS3_IS_INSTALLED="1"/TS3_IS_INSTALLED="0"/' ${SCRIPT_PATH}/configs/userconfig.cfg
}
