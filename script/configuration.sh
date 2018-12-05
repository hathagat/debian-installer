#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

start_after_install() {

  greenb() { echo $(tput bold)$(tput setaf 2)${1}$(tput sgr0); }
  ok="$(greenb [OKAY] -)"
  redb() { echo $(tput bold)$(tput setaf 1)${1}$(tput sgr0); }
  error="$(redb [ERROR] -)"

  source ${SCRIPT_PATH}/checks/nginx-check.sh; check_nginx
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/checks/php-check.sh; check_php
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/checks/openssh-check.sh; check_openssh
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/checks/fail2ban-check.sh; check_fail2ban
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/checks/unbound-check.sh; check_unbound
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/checks/dovecot-check.sh; check_dovecot
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/checks/postfix-check.sh; check_postfix
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/checks/rspamd-check.sh; check_rspamd
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/checks/lets_encrypt-check.sh; check_lets_encrypt
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/checks/firewall-check.sh; check_firewall
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/checks/mailserver-check.sh; check_mailserver
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/checks/system-check.sh; check_system
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/script/openssh_options.sh; show_ssh_key
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  dialog_msg "Please save the shown login information on next page"
  cat ${SCRIPT_PATH}/login_information.txt
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/script/openssh_options.sh; create_private_key

  if [[ ${USE_MAILSERVER} = "1" ]]; then
    dialog_msg "Please enter the shown DKIM key on next page to you DNS settings \n\n
    remove all quote signs - so it looks like that:  \n\n
    v=DKIM1; k=rsa; p=MIIBIjANBgkqh[...] "
    cat ${SCRIPT_PATH}/DKIM_KEY_ADD_TO_DNS.txt
    read -p "Continue (y/n)?" ANSW
    if [ "$ANSW" = "n" ]; then
    echo "Exit"
    exit 1
    fi
  fi

  dialog_msg "Finished after installation configuration"
}
