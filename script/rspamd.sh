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

install_rspamd() {

apt install -y lsb-release wget
wget -O- https://rspamd.com/apt-stable/gpg.key | apt-key add -
echo "deb http://rspamd.com/apt-stable/ $(lsb_release -c -s) main" > /etc/apt/sources.list.d/rspamd.list
echo "deb-src http://rspamd.com/apt-stable/ $(lsb_release -c -s) main" >> /etc/apt/sources.list.d/rspamd.list

apt update
apt install rspamd
systemctl stop rspamd

cat > /etc/rspamd/local.d/options.inc <<END
local_addrs = "127.0.0.0/8, ::1";

dns {
    nameserver = ["127.0.0.1:53:10"];
}
END

cat > /etc/rspamd/local.d/worker-normal.inc <<END
bind_socket = "localhost:11333";
### Anzahl der zu nutzenden Worker. Standard: Anzahl der virtuellen Prozessorkerne.
# count = 1
END

###hier anpassungen mit make compile anzahl

cat > /etc/rspamd/local.d/worker-controller.inc <<END
password = "$2$qecacwgrz13owkag4gqcy5y7yeqh7yh4$y6i6gn5q3538tzsn19ojchuudoauw3rzdj1z74h5us4gd3jj5e8y";
END

rspamadm pw

##dann pw hash in obere file eingeben

cat > /etc/rspamd/local.d/worker-proxy.inc <<END
bind_socket = "localhost:11332";
milter = yes;
timeout = 120s;
upstream "local" {
    default = yes;
    self_scan = yes;
}
END

cat > /etc/rspamd/local.d/logging.inc <<END
type = "file";
filename = "/var/log/rspamd/rspamd.log";
level = "error";
debug_modules = [];
END

cat > /etc/rspamd/local.d/milter_headers.conf <<END
use = ["x-spamd-bar", "x-spam-level", "authentication-results"];
authenticated_headers = ["authentication-results"];
END

mkdir /var/lib/rspamd/dkim/
rspamadm dkim_keygen -b 2048 -s 2017 -k /var/lib/rspamd/dkim/2017.key > /var/lib/rspamd/dkim/2017.txt
chown -R _rspamd:_rspamd /var/lib/rspamd/dkim
chmod 440 /var/lib/rspamd/dkim/*

##key jahr ändern 2017 -> 2018

cat /var/lib/rspamd/dkim/2017.txt

##key in dns record packen

cat > /etc/rspamd/local.d/dkim_signing.conf <<END
path = "/var/lib/rspamd/dkim/$selector.key";
selector = "2017";

### Enable DKIM signing for alias sender addresses
allow_username_mismatch = true;
END

cp -R /etc/rspamd/local.d/dkim_signing.conf /etc/rspamd/local.d/arc.conf

apt install redis-server

cat > /etc/rspamd/local.d/redis.conf <<END
servers = "127.0.0.1";
END

systemctl start rspamd

}
