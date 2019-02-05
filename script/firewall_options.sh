#!/bin/bash
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

show_open_ports()
{

trap error_exit ERR

grep -w 'OPEN_TCP=' /etc/arno-iptables-firewall/firewall.conf
OPEN_TCP_PORTS=$(grep -w 'OPEN_TCP=' /etc/arno-iptables-firewall/firewall.conf | cut -c10-)

grep -w 'OPEN_UDP' /etc/arno-iptables-firewall/firewall.conf
OPEN_UDP_PORTS=$(grep -w 'OPEN_UDP=' /etc/arno-iptables-firewall/firewall.conf | cut -c10-)

dialog_msg "Open TCP Ports: $OPEN_TCP_PORTS \n \n \n \n
Open UDP Ports: $OPEN_UDP_PORTS"
}
