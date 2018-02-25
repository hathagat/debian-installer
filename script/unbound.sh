#!/bin/bash

install_unbound() {

DEBIAN_FRONTEND=noninteractive apt-get -y install unbound dnsutils >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install unbound package"

#IPv4 workaround
rm /etc/unbound/unbound.conf
cp /usr/share/doc/unbound/examples/unbound.conf /etc/unbound/unbound.conf
sed -i "s/# interface: 192.0.2.153/  interface: 127.0.0.1/g" /etc/unbound/unbound.conf
sed -i "s/# control-interface: 127.0.0.1/  control-interface: 127.0.0.1/g" /etc/unbound/unbound.conf

su -c "unbound-anchor -a /var/lib/unbound/root.key" - unbound
systemctl restart unbound

DEBIAN_FRONTEND=noninteractive apt-get -y install resolvconf >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install resolvconf package"
echo "nameserver 127.0.0.1" >> /etc/resolvconf/resolv.conf.d/head

}
