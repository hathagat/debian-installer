#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script! 
#-------------------------------------------------------------------------------------------------------------

install_php_5() {


if [[ ${DISTOS} == 'UBUNTU' ]]; then
add-apt-repository -y ppa:ondrej/php
fi

if [[ ${DISTOS} == 'DEBIAN' ]]; then
DEBIAN_FRONTEND=noninteractive apt-get -y install apt-transport-https >>"${main_log}" 2>>"${err_log}"
wget --no-check-certificate -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg >>"${main_log}" 2>>"${err_log}"
echo "deb https://packages.sury.org/php/ stretch main" > /etc/apt/sources.list.d/php.list
fi

apt-get update -y >/dev/null 2>&1

PHPVERSION7="5.6"

if [[ ${DISTOS} == 'UBUNTU' ]]; then
	apt-get -y --assume-yes install memcached >>"${main_log}" 2>>"${err_log}"
	DEBIAN_FRONTEND=noninteractive apt-get -y install php$PHPVERSION7-common php$PHPVERSION7-gd php$PHPVERSION7-bcmath php$PHPVERSION7-zip php$PHPVERSION7 php$PHPVERSION7-cli php$PHPVERSION7-common php$PHPVERSION7-curl php$PHPVERSION7-dev php$PHPVERSION7-fpm php$PHPVERSION7-intl php$PHPVERSION7-mcrypt php$PHPVERSION7-mysql php$PHPVERSION7-soap php$PHPVERSION7-sqlite3 php$PHPVERSION7-xsl php$PHPVERSION7-xmlrpc php$PHPVERSION7-json php$PHPVERSION7-opcache php$PHPVERSION7-readline php$PHPVERSION7-xml php$PHPVERSION7-mbstring >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install php 5"
fi

if [[ ${DISTOS} == 'DEBIAN' ]]; then
	DEBIAN_FRONTEND=noninteractive apt-get -y install php$PHPVERSION7-gd php$PHPVERSION7-bcmath php$PHPVERSION7-zip php$PHPVERSION7 php$PHPVERSION7-cli php$PHPVERSION7-common php$PHPVERSION7-curl php$PHPVERSION7-dev php$PHPVERSION7-fpm php$PHPVERSION7-intl php$PHPVERSION7-mcrypt php$PHPVERSION7-mysql php$PHPVERSION7-soap php$PHPVERSION7-sqlite3 php$PHPVERSION7-xsl php$PHPVERSION7-xmlrpc php$PHPVERSION7-json php$PHPVERSION7-opcache php$PHPVERSION7-readline php$PHPVERSION7-xml php$PHPVERSION7-mbstring php$PHPVERSION7-memcached >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install php 5"
fi

#cp ${SCRIPT_PATH}/configs/php/php.ini /etc/php/$PHPVERSION7/fpm/php.ini
#cp ${SCRIPT_PATH}/configs/php/php-fpm.conf /etc/php/$PHPVERSION7/fpm/php-fpm.conf
#cp ${SCRIPT_PATH}/configs/php/www.conf /etc/php/$PHPVERSION7/fpm/pool.d/www.conf

# Configure APCu
#rm -rf /etc/php/$PHPVERSION7/mods-available/apcu.ini
#rm -rf /etc/php/$PHPVERSION7/mods-available/20-apcu.ini

#überarbeiten
#cp ${SCRIPT_PATH}/configs/php/apcu.ini /etc/php/$PHPVERSION7/mods-available/apcu.ini


#sed -i "s/^expose_php = On/expose_php = Off/g" /etc/php/$PHPVERSION7/cli/php.ini

#ln -s /etc/php/$PHPVERSION7/mods-available/apcu.ini /etc/php/$PHPVERSION7/mods-available/20-apcu.ini

systemctl -q restart nginx.service
systemctl -q restart php5-fpm.service
}
