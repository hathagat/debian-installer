#!/bin/bash

show_open_ports()
{

trap error_exit ERR

grep -w 'OPEN_TCP=' /etc/arno-iptables-firewall/firewall.conf
OPEN_TCP_PORTS=$(grep -w 'OPEN_TCP=' /etc/arno-iptables-firewall/firewall.conf | cut -c10-)

grep -w 'OPEN_UDP' /etc/arno-iptables-firewall/firewall.conf
OPEN_UDP_PORTS=$(grep -w 'OPEN_UDP=' /etc/arno-iptables-firewall/firewall.conf | cut -c10-)

echo "Open TCP Ports: $OPEN_TCP_PORTS"
echo "Open UDP Ports: $OPEN_UDP_PORTS"
}
