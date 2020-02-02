#!/bin/bash

install_fail2ban() {

trap error_exit ERR

install_packages "fail2ban"

cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local
cp ${SCRIPT_PATH}/configs/fail2ban/jail.local /etc/fail2ban/jail.local
systemctl restart fail2ban
}
