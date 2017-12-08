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

install_php_7_1() {

DEBIAN_FRONTEND=noninteractive apt-get -y install apt-transport-https >>"${main_log}" 2>>"${err_log}"
wget --no-check-certificate -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg >>"${main_log}" 2>>"${err_log}"
echo "deb https://packages.sury.org/php/ stretch main" > /etc/apt/sources.list.d/php.list
apt-get update -y >>"${main_log}" 2>>"${err_log}"

PHPVERSION7="7.1"

DEBIAN_FRONTEND=noninteractive apt-get -y install php-auth-sasl php-http-request php$PHPVERSION7-gd php$PHPVERSION7-bcmath php$PHPVERSION7-zip php-mail php-net-dime php-net-url php-pear php-apcu php$PHPVERSION7 php$PHPVERSION7-cli php$PHPVERSION7-common php$PHPVERSION7-curl php$PHPVERSION7-dev php$PHPVERSION7-fpm php$PHPVERSION7-intl php$PHPVERSION7-mcrypt php$PHPVERSION7-mysql php$PHPVERSION7-soap php$PHPVERSION7-sqlite3 php$PHPVERSION7-xsl php$PHPVERSION7-xmlrpc php-mbstring php-xml php$PHPVERSION7-json php$PHPVERSION7-opcache php$PHPVERSION7-readline php$PHPVERSION7-xml php$PHPVERSION7-mbstring php$PHPVERSION7-memcached >>"${main_log}" 2>>"${err_log}"

#option zum ändern anbieten?
#post_max_size und upload_max_filesize auf 128 mb gesetzt, Wert sollte nicht größer sein als memory_limit (256)
#sed -i 's/.*date.timezone =.*/date.timezone = Europe\/Berlin/' /etc/php/$PHPVERSION7/fpm/php.ini
#;date.timezone =
#get timezone from user config???
#sed -i 's/.*disable_functions =.*/disable_functions = pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,escapeshellarg,passthru,proc_close,proc_get_status,proc_nice,proc_open,proc_terminate,/' /etc/php/$PHPVERSION7/fpm/php.ini

cp ${SCRIPT_PATH}/configs/php/php.ini /etc/php/$PHPVERSION7/fpm/php.ini
cp ${SCRIPT_PATH}/configs/php/php-fpm.conf /etc/php/$PHPVERSION7/fpm/php-fpm.conf
cp ${SCRIPT_PATH}/configs/php/www.conf /etc/php/$PHPVERSION7/fpm/pool.d/www.conf

# Configure APCu
rm -rf /etc/php/$PHPVERSION7/mods-available/apcu.ini
rm -rf /etc/php/$PHPVERSION7/mods-available/20-apcu.ini

#überarbeiten
cp ${SCRIPT_PATH}/configs/php/apcu.ini /etc/php/$PHPVERSION7/mods-available/apcu.ini

ln -s /etc/php/$PHPVERSION7/mods-available/apcu.ini /etc/php/$PHPVERSION7/mods-available/20-apcu.ini

systemctl -q restart nginx.service
systemctl -q restart php7.1-fpm.service
}
