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

install_rainloop() {

mkdir -p /var/www/html/webmail
cd /var/www/html/webmail
wget https://github.com/RainLoop/rainloop-webmail/archive/v${RAINLOOP_VERSION}.tar.gz
tar zxvf v${RAINLOOP_VERSION}.tar.gz
mv /var/www/html/rainloop*/* /var/www/html/webmail

chown -R www-data:www-data /var/www/html/webmail

}
