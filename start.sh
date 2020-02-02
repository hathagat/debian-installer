#!/bin/bash
#################################################
#               Docker Installer                #
#                                               #
# The purpose of this script is to provide a    #
# quick way get a secure debian system running. #
#                                               #
# https://github.com/hathagat/debian-installer  #
#################################################

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

source ${SCRIPT_PATH}/configs/versions.cfg
source ${SCRIPT_PATH}/configs/userconfig.cfg
source ${SCRIPT_PATH}/script/functions.sh
source ${SCRIPT_PATH}/updates/all-services-update.sh

check_if_root() {
    if [[ $EUID -ne 0 ]]; then
       echo "Aborting! This script must be run as root..." 1>&2
       echo
       exit 1
    fi
}

display_menu() {
    clear
    cat<<EOF
    Select option:

    1)  Install
    2)  Update
    3)  System configuration

    q) Quit
----------------------------------------

Please enter your choice:
EOF
    read
    case "$REPLY" in
    "1")  clear && echo && install ;;
    "2")  clear && echo && update ;;
    "3")  clear && echo && config ;;
    "q")  exit 1 ;;
     * )  echo "invalid option" ;;
    esac
}

install() {
	echo
	echo "========================================"
	echo "    Debian Installer"
	echo "----------------------------------------"
	echo
	echo "0%   Preparing..."
	chown -R root:root ${SCRIPT_PATH}
	source ${SCRIPT_PATH}/script/logs.sh; set_logs
	source ${SCRIPT_PATH}/script/prerequisites.sh; prerequisites

	install_start=`date +%s`

	echo
	echo "10%  Checking system..."
	source ${SCRIPT_PATH}/script/functions.sh; setipaddrvars
	source ${SCRIPT_PATH}/script/checksystem.sh; check_system

	set -euo pipefail

	system_start=`date +%s`
	echo "20%  Updating system..."
	source ${SCRIPT_PATH}/script/system.sh; install_system
	system_end=`date +%s`
	systemtime=$((system_end-system_start))

	tools_start=`date +%s`
	if [[ ${INSTALL_TOOLS} = "1" ]]; then
	    echo
	    echo "30%  Installing tools..."
	    source ${SCRIPT_PATH}/script/tools.sh; install_common
	    source ${SCRIPT_PATH}/script/tools.sh; install_docker
	    source ${SCRIPT_PATH}/script/tools.sh; install_docker_compose
	fi
	tools_end=`date +%s`
	toolstime=$((tools_end-tools_start))

	openssh_start=`date +%s`
	echo
	echo "40%  Installing OpenSSH..."
	source ${SCRIPT_PATH}/script/openssh.sh; install_openssh
	openssh_end=`date +%s`
	opensshtime=$((openssh_end-openssh_start))

	fail2ban_start=`date +%s`
	echo
	echo "60%  Installing fail2ban..."
	source ${SCRIPT_PATH}/script/fail2ban.sh; install_fail2ban
	fail2ban_end=`date +%s`
	fail2bantime=$((fail2ban_end-fail2ban_start))

	firewall_start=`date +%s`
	echo
	echo "80%  Installing Firewall..."
	source ${SCRIPT_PATH}/script/firewall.sh; install_firewall
	firewall_end=`date +%s`
	firewalltime=$((firewall_end-firewall_start))

	DEBIAN_FRONTEND=noninteractive apt-get -y -qq --allow-unauthenticated autoremove >/dev/null 2>&1
	DEBIAN_FRONTEND=noninteractive apt-get -y -qq --allow-unauthenticated autoclean >/dev/null 2>&1

	rm -rf  ~/.rnd
	rm -rf  ~/.wget-hsts

	install_end=`date +%s`
	runtime=$((install_end-install_start))

	echo
	echo "100% Installation finished"
    echo

	touch ${SCRIPT_PATH}/installation_times.txt
	install_runtime_string="Installation runtime for"
	echo "----------------------------------------------------------------------------------------" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string System preparation in seconds: ${systemtime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string Common tools in seconds: ${toolstime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string SSH in seconds: ${opensshtime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string fail2ban in seconds: ${fail2bantime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string Firewall in seconds: ${firewalltime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "$install_runtime_string The whole installation seconds: ${runtime}" >> ${SCRIPT_PATH}/installation_times.txt
	echo "----------------------------------------------------------------------------------------" >> ${SCRIPT_PATH}/installation_times.txt
	echo "" >> ${SCRIPT_PATH}/installation_times.txt

	date=$(date +"%d-%m-%Y")
	sed -i 's/INSTALL_DATE="0"/INSTALL_DATE="'${date}'"/' ${SCRIPT_PATH}/configs/userconfig.cfg

	source ${SCRIPT_PATH}/script/configuration.sh; list_infos
	exec bash
}

update() {
	source ${SCRIPT_PATH}/update.sh
	# TODO
	echo "Updating Script"
	update_all_services
	update_script

	GIT_LOCAL_FILES_HEAD=$(git rev-parse --short HEAD)
    GIT_LOCAL_FILES_HEAD_LAST_COMMIT=$(git log -1 --date=short --pretty=format:%cd)
	echo "Finished updating to Version ${GIT_LOCAL_FILES_HEAD} from ${GIT_LOCAL_FILES_HEAD_LAST_COMMIT}"

	display_menu
}

config() {
    # TODO
	source ${SCRIPT_PATH}/menus/after_install_config_menu.sh; menu_options_after_install
	source ${SCRIPT_PATH}/menus/services_menu.sh; menu_options_services

	display_menu
}

echo
echo "========================================"
echo "    Debian Installer"
echo "----------------------------------------"
echo

check_if_root
display_menu
