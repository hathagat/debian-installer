#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

start_after_install() {

  source ${SCRIPT_PATH}/configs/userconfig.cfg
  source ${SCRIPT_PATH}/script/functions.sh
  greenb() { echo $(tput bold)$(tput setaf 2)${1}$(tput sgr0); }
  ok="$(greenb [OKAY] -)"
  redb() { echo $(tput bold)$(tput setaf 1)${1}$(tput sgr0); }
  error="$(redb [ERROR] -)"

  source ${SCRIPT_PATH}/checks/nginx-check.sh; check_nginx
  #dialog_yesno_configuration
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/checks/php-check.sh; check_php
  #dialog_yesno_configuration
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/checks/openssh-check.sh; check_openssh
  #dialog_yesno_configuration
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/checks/fail2ban-check.sh; check_fail2ban
  #dialog_yesno_configuration
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/checks/unbound-check.sh; check_unbound
  #dialog_yesno_configuration
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/checks/dovecot-check.sh; check_dovecot
  #dialog_yesno_configuration
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/checks/postfix-check.sh; check_postfix
  #dialog_yesno_configuration
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/checks/rspamd-check.sh; check_rspamd
  #dialog_yesno_configuration
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/checks/lets_encrypt-check.sh; check_lets_encrypt
  #dialog_yesno_configuration
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/checks/firewall-check.sh; check_firewall
  #dialog_yesno_configuration
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/checks/mailman-check.sh; check_mailman
  #dialog_yesno_configuration
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/checks/mailserver-check.sh; check_mailserver
  #dialog_yesno_configuration
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/checks/system-check.sh; check_system
  #dialog_yesno_configuration
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

  source ${SCRIPT_PATH}/configs/versions.cfg
	source ${SCRIPT_PATH}/script/configuration.sh; show_ssh_key
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

	source ${SCRIPT_PATH}/script/configuration.sh; show_login_information.txt
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi

	source ${SCRIPT_PATH}/script/configuration.sh; create_private_key

  if [[ ${USE_MAILSERVER} = "1" ]]; then
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  source ${SCRIPT_PATH}/script/configuration.sh; show_dkim_key
  fi
  fi

	dialog --backtitle "NeXt Server Installation" --msgbox "Finished after installation configuration" $HEIGHT $WIDTH
}

show_ssh_key() {
dialog --backtitle "NeXt Server Configuration" --msgbox "Please save the shown SSH privatekey on next page into a textfile on your PC. \n\n
Important: \n
In Putty you have only mark the text. Do not Press STRG+C!" $HEIGHT $WIDTH
#dialog --title "Your SSH Privatekey" --tab-correct --exit-label "ok" --textbox ${SCRIPT_PATH}/ssh_privatekey.txt 50 200
cat ${SCRIPT_PATH}/ssh_privatekey.txt
}

show_login_information.txt() {
dialog_msg "Please save the shown login information on next page"
#dialog --title "Your Server Logininformations" --tab-correct --exit-label "ok" --textbox ${SCRIPT_PATH}/login_information.txt 50 200
cat ${SCRIPT_PATH}/login_information.txt
}

create_private_key() {
dialog --backtitle "NeXt Server Configuration" --msgbox "You have to download the latest PuTTYgen \n (https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) \n \n
Start the program and click on Conversions- Import key. \n
Now select the Text file, where you saved the ssh_privatekey. \n
After entering your SSH Password, you have to switch the paramter from RSA to ED25519. \n
In the last step click on save private key - done! \n \n
Dont forget to change your SSH Port in PuTTY!" $HEIGHT $WIDTH
}

show_dkim_key() {
dialog --backtitle "NeXt Server Configuration" --msgbox "Please enter the shown DKIM key on next page to you DNS settings \n\n
remove all quote signs - so it looks like that:  \n\n
v=DKIM1; k=rsa; p=MIIBIjANBgkqh[...] "$HEIGHT $WIDTH
#dialog --title "Your Server Logininformations" --tab-correct  --exit-label "ok"--textbox ${SCRIPT_PATH}/DKIM_KEY_ADD_TO_DNS.txt 50 200
cat ${SCRIPT_PATH}/DKIM_KEY_ADD_TO_DNS.txt
}
