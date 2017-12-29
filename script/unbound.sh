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

install_unbound() {

DEBIAN_FRONTEND=noninteractive apt-get -y install unbound dnsutils >>"${main_log}" 2>>"${err_log}"

#IPv4 workaround
rm /etc/unbound/unbound.conf
cp /usr/share/doc/unbound/examples/unbound.conf /etc/unbound/unbound.conf
sed -i "s/# interface: 192.0.2.153/  interface: 127.0.0.1/g" /usr/share/doc/unbound/examples/unbound.conf
sed -i "s/# control-interface: 127.0.0.1/  control-interface: 127.0.0.1/g" /usr/share/doc/unbound/examples/unbound.conf

su -c "unbound-anchor -a /var/lib/unbound/root.key" - unbound
systemctl reload unbound

DEBIAN_FRONTEND=noninteractive apt-get -y install resolvconf >>"${main_log}" 2>>"${err_log}"
echo "nameserver 127.0.0.1" >> /etc/resolvconf/resolv.conf.d/head

}
