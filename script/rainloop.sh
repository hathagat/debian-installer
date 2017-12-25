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
wget -qO- https://repository.rainloop.net/installer.php | php

mkdir -p /etc/nginx/sites-custom/

cat >> /etc/nginx/sites-custom/rainloop.conf << 'EOF1'
location ~ ^/webmail {
    alias /var/www/rainloop/$1;
    location ~ ^/vma/(.*\.(js|css|gif|jpg|png|ico))$ {
        alias /var/www/rainloop/$1;
    }
    rewrite ^/webmail(.*)$ /vma/index.php last;
    location ~ ^/webmail(.+\.php)$ {
        alias /var/www/rainloop/$1;
        fastcgi_pass unix:/var/run/php/php7.1-fpm.sock;
        fastcgi_index index.php;
        charset utf8;
        include fastcgi_params;
        fastcgi_param DOCUMENT_ROOT /var/www/rainloop/$1;
    }
}
EOF1

if [[ ${USE_PHP7_2} == '1' ]]; then
	sed -i 's/fastcgi_pass unix:\/var\/run\/php\/php7.0-fpm.sock\;/fastcgi_pass unix:\/var\/run\/php\/php7.2-fpm.sock\;/g' /etc/nginx/sites-custom/vimbadmin.conf || error_exit "Failed to sed fastcgi_pass unix! Aborting"
fi

}
