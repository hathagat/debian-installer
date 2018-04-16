#!/bin/bash

SCRIPT_PATH="/root/NeXt-Server"

source ${SCRIPT_PATH}/configs/versions.cfg
source ${SCRIPT_PATH}/configs/userconfig.cfg

install() {
	install_start=`date +%s`
	echo "0" | dialog --gauge "Checking your system..." 10 70 0
	source ${SCRIPT_PATH}/script/logs.sh; set_logs
	source ${SCRIPT_PATH}/script/functions.sh
	source ${SCRIPT_PATH}/script/prerequisites.sh; prerequisites
	source ${SCRIPT_PATH}/script/functions.sh; setipaddrvars
	source ${SCRIPT_PATH}/script/checksystem.sh; check_system

	if [[ ${USE_CONFIGHELPER} = "1" ]]; then
		source ${SCRIPT_PATH}/confighelper.sh; confighelper_userconfig
	fi

	system_start=`date +%s`
	echo "5" | dialog --gauge "Updating system..." 10 70 0
	source ${SCRIPT_PATH}/script/system.sh; install_system
	system_end=`date +%s`
	systemtime=$((system_end-system_start))

	common_start=`date +%s`
	if [[ ${INSTALL_COMMON} = "1" ]]; then
	    echo "10" | dialog --gauge "Installing common stuff..." 10 70 0
	    source ${SCRIPT_PATH}/script/common.sh; install_common
	fi
	common_end=`date +%s`
	commontime=$((common_end-common_start))

	openssl_start=`date +%s`
	echo "20" | dialog --gauge "Installing OpenSSL..." 10 70 0
	source ${SCRIPT_PATH}/script/openssl.sh; install_openssl
	openssl_end=`date +%s`
	openssltime=$((openssl_end-openssl_start))

	openssh_start=`date +%s`
	echo "30" | dialog --gauge "Installing OpenSSH..." 10 70 0
	source ${SCRIPT_PATH}/script/openssh.sh; install_openssh
	openssh_end=`date +%s`
	opensshtime=$((openssh_end-openssh_start))

	fail2ban_start=`date +%s`
	echo "40" | dialog --gauge "Installing fail2ban..." 10 70 0
	source ${SCRIPT_PATH}/script/fail2ban.sh; install_fail2ban
	fail2ban_end=`date +%s`
	fail2bantime=$((fail2ban_end-fail2ban_start))

	mariadb_start=`date +%s`
	if [[ ${INSTALL_MARIADB} = "1" ]]; then
	    echo "50" | dialog --gauge "Installing MariaDB..." 10 70 0
		source ${SCRIPT_PATH}/script/mariadb.sh; install_mariadb
	fi
	maria_end=`date +%s`
	mariatime=$((maria_end-mariadb_start))

	nginx_start=`date +%s`
	if [[ ${INSTALL_NGINX} = "1" ]]; then
	    echo "60" | dialog --gauge "Installing Nginx Addons..." 10 70 0
	    source ${SCRIPT_PATH}/script/nginx_addons.sh; install_nginx_addons

	    echo "65" | dialog --gauge "Installing Nginx..." 10 70 0
	    source ${SCRIPT_PATH}/script/nginx.sh; install_nginx

	echo "50" | dialog --gauge "Installing LE..." 10 70 0
	source ${SCRIPT_PATH}/script/lets_encrypt.sh; install_lets_encrypt
	source ${SCRIPT_PATH}/script/lets_encrypt.sh; create_nginx_cert

	    echo "75" | dialog --gauge "Installing Nginx vHost..." 10 70 0
	    source ${SCRIPT_PATH}/script/nginx_vhost.sh; install_nginx_vhost
	fi
	nginx_end=`date +%s`
	nginxtime=$((nginx_end-nginx_start))

	php_start=`date +%s`
	if [[ ${INSTALL_PHP} = "1" ]]; then
	    echo "80" | dialog --gauge "Installing PHP..." 10 70 0
        if [[ ${USE_PHP5="1"} = "1" ]]; then
		    source ${SCRIPT_PATH}/script/php5_6.sh; install_php_5
	    fi
		if [[ ${USE_PHP7_1} = "1" ]]; then
		    source ${SCRIPT_PATH}/script/php7_1.sh; install_php_7_1
	    fi
	    if [[ ${USE_PHP7_2} = "1" ]]; then
		    source ${SCRIPT_PATH}/script/php7_2.sh; install_php_7_2
	    fi
	fi
	php_end=`date +%s`
	phptime=$((php_end-php_start))

	mailserver_start=`date +%s`
	if [[ ${USE_MAILSERVER} = "1" ]]; then
	    echo "90" | dialog --gauge "Installing Mailserver..." 10 70 0
		source ${SCRIPT_PATH}/script/unbound.sh; install_unbound
		source ${SCRIPT_PATH}/script/mailserver.sh; install_mailserver
		source ${SCRIPT_PATH}/script/dovecot.sh; install_dovecot
		source ${SCRIPT_PATH}/script/postfix.sh; install_postfix
		source ${SCRIPT_PATH}/script/rspamd.sh; install_rspamd
		source ${SCRIPT_PATH}/script/rainloop.sh; install_rainloop
		source ${SCRIPT_PATH}/script/mailman.sh; install_mailman
	fi
	mailserver_end=`date +%s`
	mailservertime=$((mailserver_end-mailserver_start))

	firewall_start=`date +%s`
	echo "95" | dialog --gauge "Installing Firewall..." 10 70 0
	source ${SCRIPT_PATH}/script/firewall.sh; install_firewall
	firewall_end=`date +%s`
	firewalltime=$((firewall_end-firewall_start))

	apt-get -y autoremove >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to autoremove packages"
	apt-get autoclean >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to autoclean packages"

    rm -rf  ~/.rnd
    rm -rf  ~/.wget-hsts

	install_end=`date +%s`
	runtime=$((install_end-install_start))

	touch ${SCRIPT_PATH}/installation_times.txt
	install_runtime_string="NeXt Server Installation runtime for"
	echo "----------------------------------------------------------------------------------------" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string System preparation in seconds: ${systemtime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string Common Tools in seconds: ${commontime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string SSL in seconds: ${openssltime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string SSH in seconds: ${opensshtime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string fail2ban in seconds: ${fail2bantime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string MariaDB in seconds: ${mariatime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string Nginx in seconds: ${nginxtime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string PHP in seconds: ${phptime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string Mailserver in seconds: ${mailservertime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string Firewall in seconds: ${firewalltime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string the whole Installation seconds: ${runtime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "----------------------------------------------------------------------------------------" >> ${SCRIPT_PATH}/installation_times.txt
	echo "" >> ${SCRIPT_PATH}/installation_times.txt

	if [[ ${USE_MAILSERVER} = "1" ]]; then
		sed -i 's/NXT_IS_INSTALLED_MAILSERVER="0"/NXT_IS_INSTALLED_MAILSERVER="1"/' ${SCRIPT_PATH}/configs/userconfig.cfg
	else
		sed -i 's/NXT_IS_INSTALLED="0"/NXT_IS_INSTALLED="1"/' ${SCRIPT_PATH}/configs/userconfig.cfg
	fi

	date=$(date +"%d-%m-%Y")
	sed -i 's/NXT_INSTALL_DATE="0"/NXT_INSTALL_DATE="'${date}'"/' ${SCRIPT_PATH}/configs/userconfig.cfg

	echo "100" | dialog --gauge "NeXt Server Installation finished!" 10 70 0

	# Start Full Config after installation
	source ${SCRIPT_PATH}/script/configuration.sh; start_after_install
}
