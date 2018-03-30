#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
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
systemctl restart unbound

DEBIAN_FRONTEND=noninteractive apt-get -y install resolvconf >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install resolvconf package"
echo "nameserver 127.0.0.1" >> /etc/resolvconf/resolv.conf.d/head

}
