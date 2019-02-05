#!/bin/bash
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_unbound() {

trap error_exit ERR

install_packages "unbound dnsutils"

sudo -u  unbound unbound-anchor -a /var/lib/unbound/root.key
systemctl stop unbound

systemctl start unbound

install_packages "resolvconf"
echo "nameserver 127.0.0.1" >> /etc/resolvconf/resolv.conf.d/head

}
