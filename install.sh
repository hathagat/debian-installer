#!/bin/bash
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

SCRIPT_PATH="/root/NeXt-Server"

source ${SCRIPT_PATH}/configs/versions.cfg
source ${SCRIPT_PATH}/configs/userconfig.cfg

	install_start=`date +%s`
	source ${SCRIPT_PATH}/script/functions.sh

	progress_gauge "0" "Checking your system..."
	source ${SCRIPT_PATH}/script/logs.sh; set_logs
	source ${SCRIPT_PATH}/script/functions.sh; setipaddrvars
	source ${SCRIPT_PATH}/script/checksystem.sh; check_system

	source ${SCRIPT_PATH}/confighelper.sh; confighelper_userconfig

	set -euxo -o pipefail
	progress_gauge "0" "Installing System..."
	source ${SCRIPT_PATH}/script/system.sh; install_system

	progress_gauge "1" "Installing OpenSSL..."
	source ${SCRIPT_PATH}/script/openssl.sh; install_openssl

	progress_gauge "31" "Installing OpenSSH..."
	source ${SCRIPT_PATH}/script/openssh.sh; install_openssh

	progress_gauge "32" "Installing fail2ban..."
	source ${SCRIPT_PATH}/script/fail2ban.sh; install_fail2ban

	progress_gauge "33" "Installing MariaDB..."
	source ${SCRIPT_PATH}/script/mariadb.sh; install_mariadb

	progress_gauge "34" "Installing Nginx Addons..."
	source ${SCRIPT_PATH}/script/nginx_addons.sh; install_nginx_addons

	progress_gauge "40" "Installing Nginx..."
	source ${SCRIPT_PATH}/script/nginx.sh; install_nginx

	progress_gauge "65" "Installing Let's Encrypt..."
	source ${SCRIPT_PATH}/script/lets_encrypt.sh; install_lets_encrypt

	progress_gauge "68" "Creating Let's Encrypt Certificate..."
	source ${SCRIPT_PATH}/script/lets_encrypt.sh; create_nginx_cert

	progress_gauge "74" "Installing PHP..."
	source ${SCRIPT_PATH}/script/php7_2.sh; install_php_7_2

	progress_gauge "75" "Installing Mailserver..."
	if [[ ${USE_MAILSERVER} = "1" ]]; then
		source ${SCRIPT_PATH}/script/unbound.sh; install_unbound
		source ${SCRIPT_PATH}/script/mailserver.sh; install_mailserver
		source ${SCRIPT_PATH}/script/dovecot.sh; install_dovecot
		source ${SCRIPT_PATH}/script/postfix.sh; install_postfix
		source ${SCRIPT_PATH}/script/rspamd.sh; install_rspamd
		source ${SCRIPT_PATH}/script/rainloop.sh; install_rainloop
		source ${SCRIPT_PATH}/script/managevmail.sh; install_managevmail
	fi

	progress_gauge "96" "Installing Firewall..."
	source ${SCRIPT_PATH}/script/firewall.sh; install_firewall
	install_end=`date +%s`
	runtime=$((install_end-install_start))

	if [[ ${USE_MAILSERVER} = "1" ]]; then
		sed -i 's/NXT_IS_INSTALLED_MAILSERVER="0"/NXT_IS_INSTALLED_MAILSERVER="1"/' ${SCRIPT_PATH}/configs/userconfig.cfg
	else
		sed -i 's/NXT_IS_INSTALLED="0"/NXT_IS_INSTALLED="1"/' ${SCRIPT_PATH}/configs/userconfig.cfg
	fi

	date=$(date +"%d-%m-%Y")
	sed -i 's/NXT_INSTALL_DATE="0"/NXT_INSTALL_DATE="'${date}'"/' ${SCRIPT_PATH}/configs/userconfig.cfg
	sed -i 's/NXT_INSTALL_TIME_SECONDS="0"/NXT_INSTALL_TIME_SECONDS="'${runtime}'"/' ${SCRIPT_PATH}/configs/userconfig.cfg

	# Start Full Config after installation
	source ${SCRIPT_PATH}/script/configuration.sh; start_after_install
