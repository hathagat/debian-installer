#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_unbound() {

install_packages "unbound dnsutils"

#IPv4 workaround
rm /etc/unbound/unbound.conf
cp /usr/share/doc/unbound/examples/unbound.conf /etc/unbound/unbound.conf
sed -i "s/# interface: 192.0.2.153/  interface: 127.0.0.1/g" /etc/unbound/unbound.conf
sed -i "s/# control-interface: 127.0.0.1/  control-interface: 127.0.0.1/g" /etc/unbound/unbound.conf

su -c "unbound-anchor -a /var/lib/unbound/root.key" - unbound
systemctl stop unbound

systemctl start unbound

install_packages "resolvconf"
echo "nameserver 127.0.0.1" >> /etc/resolvconf/resolv.conf.d/head

}
