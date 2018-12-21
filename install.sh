#!/bin/bash

source ${SCRIPT_PATH}/configs/versions.cfg
source ${SCRIPT_PATH}/configs/userconfig.cfg

install() {
	install_start=`date +%s`
	echo "0" | dialog --gauge "Checking your system..." 10 70 0
	source ${SCRIPT_PATH}/script/logs.sh; set_logs
	source ${SCRIPT_PATH}/script/functions.sh
	source ${SCRIPT_PATH}/script/functions.sh; setipaddrvars
	source ${SCRIPT_PATH}/script/checksystem.sh; check_system

	system_start=`date +%s`
	echo "10" | dialog --gauge "Updating system..." 10 70 0
	source ${SCRIPT_PATH}/script/system.sh; install_system
	system_end=`date +%s`
	systemtime=$((system_end-system_start))

	common_start=`date +%s`
	if [[ ${INSTALL_COMMON} = "1" ]]; then
	    echo "20" | dialog --gauge "Installing common stuff..." 10 70 0
	    source ${SCRIPT_PATH}/script/common.sh; install_common
	    source ${SCRIPT_PATH}/script/common.sh; install_docker
	    source ${SCRIPT_PATH}/script/common.sh; install_docker_compose
	fi
	common_end=`date +%s`
	commontime=$((common_end-common_start))

	openssh_start=`date +%s`
	echo "40" | dialog --gauge "Installing OpenSSH..." 10 70 0
	source ${SCRIPT_PATH}/script/openssh.sh; install_openssh
	openssh_end=`date +%s`
	opensshtime=$((openssh_end-openssh_start))

	fail2ban_start=`date +%s`
	echo "60" | dialog --gauge "Installing fail2ban..." 10 70 0
	source ${SCRIPT_PATH}/script/fail2ban.sh; install_fail2ban
	fail2ban_end=`date +%s`
	fail2bantime=$((fail2ban_end-fail2ban_start))

	firewall_start=`date +%s`
	echo "80" | dialog --gauge "Installing Firewall..." 10 70 0
	source ${SCRIPT_PATH}/script/firewall.sh; install_firewall
	firewall_end=`date +%s`
	firewalltime=$((firewall_end-firewall_start))

  DEBIAN_FRONTEND=noninteractive apt-get -y -qq --allow-unauthenticated autoremove >/dev/null 2>&1
  DEBIAN_FRONTEND=noninteractive apt-get -y -qq --allow-unauthenticated autoclean >/dev/null 2>&1

  rm -rf  ~/.rnd
  rm -rf  ~/.wget-hsts

	install_end=`date +%s`
	runtime=$((install_end-install_start))

	touch ${SCRIPT_PATH}/installation_times.txt
	install_runtime_string="NeXt Server Installation runtime for"
	echo "----------------------------------------------------------------------------------------" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string System preparation in seconds: ${systemtime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string Common Tools in seconds: ${commontime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string SSH in seconds: ${opensshtime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string fail2ban in seconds: ${fail2bantime}" >> ${SCRIPT_PATH}/installation_times.txtt
	echo "$install_runtime_string Firewall in seconds: ${firewalltime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string the whole Installation seconds: ${runtime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "----------------------------------------------------------------------------------------" >> ${SCRIPT_PATH}/installation_times.txt
	echo "" >> ${SCRIPT_PATH}/installation_times.txt

	date=$(date +"%d-%m-%Y")
	sed -i 's/NXT_INSTALL_DATE="0"/NXT_INSTALL_DATE="'${date}'"/' ${SCRIPT_PATH}/configs/userconfig.cfg

	echo "100" | dialog --gauge "Installation finished!" 10 70 0

	# Start Full Config after installation
	source ${SCRIPT_PATH}/script/configuration.sh; start_after_install
}
