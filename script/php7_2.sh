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

install_php_7_2() {

if [[ ${DISTOS} == 'UBUNTU' ]]; then
add-apt-repository -y ppa:ondrej/php
fi

if [[ ${DISTOS} == 'DEBIAN' ]]; then
DEBIAN_FRONTEND=noninteractive apt-get -y install apt-transport-https >>"${main_log}" 2>>"${err_log}"
wget --no-check-certificate -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg >>"${main_log}" 2>>"${err_log}"
echo "deb https://packages.sury.org/php/ stretch main" > /etc/apt/sources.list.d/php.list
fi

apt-get update -y >/dev/null 2>&1

PHPVERSION7="7.2"

if [[ ${DISTOS} == 'UBUNTU' ]]; then
	apt-get -y --assume-yes install memcached >>"${main_log}" 2>>"${err_log}"
	DEBIAN_FRONTEND=noninteractive apt-get -y install php$PHPVERSION7-common php-auth-sasl php-http-request php$PHPVERSION7-gd php$PHPVERSION7-bcmath php$PHPVERSION7-zip php-mail php-net-dime php-net-url php-pear php-apcu php$PHPVERSION7 php$PHPVERSION7-cli php$PHPVERSION7-common php$PHPVERSION7-curl php$PHPVERSION7-dev php$PHPVERSION7-fpm php$PHPVERSION7-intl php$PHPVERSION7-mcrypt php$PHPVERSION7-mysql php$PHPVERSION7-soap php$PHPVERSION7-sqlite3 php$PHPVERSION7-xsl php$PHPVERSION7-xmlrpc php-mbstring php-xml php$PHPVERSION7-json php$PHPVERSION7-opcache php$PHPVERSION7-readline php$PHPVERSION7-xml php$PHPVERSION7-mbstring php-memcached >>"${main_log}" 2>>"${err_log}"
fi

if [[ ${DISTOS} == 'DEBIAN' ]]; then
	DEBIAN_FRONTEND=noninteractive apt-get -y install php-auth-sasl php-http-request php$PHPVERSION7-gd php$PHPVERSION7-bcmath php$PHPVERSION7-zip php-mail php-net-dime php-net-url php-pear php-apcu php$PHPVERSION7 php$PHPVERSION7-cli php$PHPVERSION7-common php$PHPVERSION7-curl php$PHPVERSION7-dev php$PHPVERSION7-fpm php$PHPVERSION7-intl php$PHPVERSION7-mcrypt php$PHPVERSION7-mysql php$PHPVERSION7-soap php$PHPVERSION7-sqlite3 php$PHPVERSION7-xsl php$PHPVERSION7-xmlrpc php-mbstring php-xml php$PHPVERSION7-json php$PHPVERSION7-opcache php$PHPVERSION7-readline php$PHPVERSION7-xml php$PHPVERSION7-mbstring php$PHPVERSION7-memcached >>"${main_log}" 2>>"${err_log}"
fi

cp ${SCRIPT_PATH}/configs/php/php.ini /etc/php/$PHPVERSION7/fpm/php.ini
cp ${SCRIPT_PATH}/configs/php/php-fpm.conf /etc/php/$PHPVERSION7/fpm/php-fpm.conf

sed -i "s/php7.1/php7.2/g" /etc/php/$PHPVERSION7/fpm/php-fpm.conf >>"${main_log}" 2>>"${err_log}"
sed -i "s/7.1/7.2/g" /etc/php/$PHPVERSION7/fpm/php-fpm.conf >>"${main_log}" 2>>"${err_log}"

cp ${SCRIPT_PATH}/configs/php/www.conf /etc/php/$PHPVERSION7/fpm/pool.d/www.conf
sed -i "s/7.1/7.2/g" /etc/php/$PHPVERSION7/fpm/pool.d/www.conf >>"${main_log}" 2>>"${err_log}"

# Configure APCu
rm -rf /etc/php/$PHPVERSION7/mods-available/apcu.ini
rm -rf /etc/php/$PHPVERSION7/mods-available/20-apcu.ini

#überarbeiten
cp ${SCRIPT_PATH}/configs/php/apcu.ini /etc/php/$PHPVERSION7/mods-available/apcu.ini

ln -s /etc/php/$PHPVERSION7/mods-available/apcu.ini /etc/php/$PHPVERSION7/mods-available/20-apcu.ini

systemctl -q restart nginx.service
systemctl -q restart php$PHPVERSION7-fpm.service
}
