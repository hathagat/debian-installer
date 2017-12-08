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
SCRIPT_PATH="/root/NeXt-Server"

source ${SCRIPT_PATH}/configs/versions.cfg
source ${SCRIPT_PATH}/configs/userconfig.cfg

	install_start=`date +%s`
	echo "0" | dialog --gauge "Checking your system..." 10 70 0
	source ${SCRIPT_PATH}/script/logs.sh; set_logs
	source ${SCRIPT_PATH}/script/functions.sh
	source ${SCRIPT_PATH}/script/prerequisites.sh; prerequisites
	source ${SCRIPT_PATH}/script/checksystem.sh; check_system
	system_end=`date +%s`
	systemtime=$((system_end-install_start))

  system_start=`date +%s`
	echo "1" | dialog --gauge "Installing System..." 10 70 0
	source ${SCRIPT_PATH}/script/system.sh; install_system
	system_end=`date +%s`
	systemtime=$((system_end-system_start))

	openssl_start=`date +%s`
	echo "2" | dialog --gauge "Installing OpenSSL..." 10 70 0
	source ${SCRIPT_PATH}/script/openssl.sh; install_openssl
	openssl_end=`date +%s`
	openssltime=$((openssl_end-openssl_start))

	openssh_start=`date +%s`
	echo "5" | dialog --gauge "Installing OpenSSH..." 10 70 0
	source ${SCRIPT_PATH}/script/openssh.sh; install_openssh
	openssh_end=`date +%s`
	opensshtime=$((openssh_end-openssh_start))

	fail2ban_start=`date +%s`
	echo "10" | dialog --gauge "Installing fail2ban..." 10 70 0
	source ${SCRIPT_PATH}/script/fail2ban.sh; install_fail2ban
	fail2ban_end=`date +%s`
	fail2bantime=$((fail2ban_end-fail2ban_start))

	nginx_start=`date +%s`
	echo "12" | dialog --gauge "Installing Nginx Addons..." 10 70 0
	source ${SCRIPT_PATH}/script/nginx_addons.sh; install_nginx_addons

	echo "15" | dialog --gauge "Installing Nginx..." 10 70 0
	source ${SCRIPT_PATH}/script/nginx.sh; install_nginx

	echo "15" | dialog --gauge "Installing LE..." 10 70 0
	source ${SCRIPT_PATH}/script/lets_encrypt.sh; install_lets_encrypt

	echo "25" | dialog --gauge "Installing Nginx Vhost..." 10 70 0
	source ${SCRIPT_PATH}/script/nginx_vhost.sh; install_nginx_vhost
	nginx_end=`date +%s`
	nginxtime=$((nginx_end-nginx_start))

	echo "45" | dialog --gauge "Installing PHP..." 10 70 0
	php_start=`date +%s`
	if [[ ${USE_PHP7_1} = "1" ]]; then
		source ${SCRIPT_PATH}/script/php7_1.sh; install_php_7_1
	fi

	if [[ ${USE_PHP7_2} = "1" ]]; then
		source ${SCRIPT_PATH}/script/php7_2.sh; install_php_7_2
	fi
	php_end=`date +%s`
	phptime=$((php_end-php_start))

	firewall_start=`date +%s`
	echo "55" | dialog --gauge "Installing Firewall..." 10 70 0
	source ${SCRIPT_PATH}/script/firewall.sh; install_firewall
	firewall_end=`date +%s`
	firewalltime=$((firewall_end-firewall_start))

	install_end=`date +%s`
	runtime=$((install_end-install_start))

	touch ${SCRIPT_PATH}/installation_times.txt
	install_runtime_string="NeXt Server Installation runtime for"
	echo "----------------------------------------------------------------------------------------" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string System preparation in seconds: ${systemtime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string SSL in seconds: ${openssltime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string SSH in seconds: ${opensshtime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string fail2ban in seconds: ${fail2bantime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string Nginx in seconds: ${nginxtime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string PHP in seconds: ${phptime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string Firewall in seconds: ${firewalltime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string the whole Installation seconds: ${runtime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "----------------------------------------------------------------------------------------" >> ${SCRIPT_PATH}/installation_times.txt
	echo "" >> ${SCRIPT_PATH}/installation_times.txt

	echo "100" | dialog --gauge "NeXt Server Installation finished!" 10 70 0
