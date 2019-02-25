#!/bin/bash

password() {
  while true; do
    random_password=$(openssl rand -base64 40 | tr -d / | cut -c -32 | grep -P '(?=^.{8,255}$)(?=^[^\s]*$)(?=.*\d)(?=.*[A-Z])(?=.*[a-z])')

      if [ -z "$random_password" ]
      then
            echo "empty" > /dev/null 2>&1
      else
            echo "$random_password"
            break
      fi
  done
}

# bash generate random n character alphanumeric string (upper and lowercase) and
username() {
  while true; do
  random_username=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
    if [ -z "$random_username" ]
    then
          echo "empty" > /dev/null 2>&1
    else
          echo "$random_username"
          break;
    fi
done
}

setipaddrvars() {
  HOST=$(hostname)
  IPADR=$(ip route list | awk '/src/ {print $9}')
  INTERFACE=$(ip route list | awk '/default/ {print $5}')
  CIDR=$(ip -o -f inet addr show ${INTERFACE} | awk '{print $4}')
  BROADCAST=$(ip -o -f inet addr show ${INTERFACE} | awk '{print $6}')
  GATEWAY=$(ip route list | awk '/default/ {print $3}')
  FQDNIP=$(dig @9.9.9.9 +short ${MYDOMAIN})
  WWWIP=$(dig @9.9.9.9 +short www.${MYDOMAIN})
  CHECKRDNS=$(dig @9.9.9.9 -x ${IPADR} +short)
}

get_domain() {
  LOCAL_IP=$(hostname -I)
  POSSIBLE_DOMAIN=$(dig -x ${LOCAL_IP} +short)
  DETECTED_DOMAIN=$(echo "${POSSIBLE_DOMAIN}" | awk -v FS='.' '{print $2 "." $3}')
}

menu() {
CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
				--no-cancel \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)
}

function dialog_info() {
  dialog --backtitle "Debian Installer" --infobox "$1" 40 80
}

function dialog_msg() {
  dialog --backtitle "Debian Installer" --msgbox "$1" 40 80
}

function dialog_yesno_configuration() {
  dialog --backtitle "Debian Installer" \
--yesno "Continue with server configuration?" 7 60

CHOICE=$?
case $CHOICE in
   1)
        echo "Skipped the Configuration!"
        exit 1;;
esac
}

CHECK_E_MAIL="^[a-zA-Z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-zA-Z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?\$"
CHECK_PASSWORD="^[A-Za-z0-9]*$"
####not perfectly working!!!!
CHECK_DOMAIN="^[a-zA-Z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-zA-Z0-9!#$%&'*+/=?^_\`{|}~-]+)*.([a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z])?\$"

CURRENT_DATE=`date +%Y-%m-%d:%H:%M:%S`

function check_service() {
  if systemctl is-failed --quiet $1
  then
    echo "${error} $1 is not running!"
  else
    echo "${ok} $1 is running!"
  fi
}

function wget_tar() {
  wget --no-check-certificate $1 --tries=3 >>"${main_log}" 2>>"${err_log}"
  ERROR=$?
  if [[ "$ERROR" != '0' ]]; then
     echo "Error: $1 download failed."
     exit
  fi
}

function tar_file() {
  tar -xzf $1 >>"${main_log}" 2>>"${err_log}"
  ERROR=$?
  if [[ "$ERROR" != '0' ]]; then
     echo "Error: $1 is corrupted."
     exit
   fi
  rm $1
}

function unzip_file() {
  unzip $1 >>"${main_log}" 2>>"${err_log}"
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
     echo "Error: $1 is corrupted."
     exit
  fi
}

function install_packages() {
  DEBIAN_FRONTEND=noninteractive apt-get -y -qq --no-install-recommends --allow-unauthenticated install $1 >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install $1 packages"
  ERROR=$?
  if [[ "$ERROR" != '0' ]]; then
     echo "Error: $1 had an error during installation."
     exit
  fi
}

error_exit()
{
	echo "$1" 1>&2
  USED_OS=$(lsb_release -is)
  echo "Visit https://github.com/hathagat/debian-installer/issues/new to add the Issue on Github!"
  echo "Your Issue is: $1"
  echo "Your used OS is: $USED_OS"
	exit 1
}

show_login_information()
{
  dialog_msg "Please save the shown login information on next page"
  cat ${SCRIPT_PATH}/login_information.txt
}

continue_to_menu()
{
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi
  bash ${SCRIPT_PATH}/nxt.sh
}

continue_or_exit()
{
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit 1
  fi
}

progress_gauge()
{
  echo "$1" | dialog --gauge "$2" 10 70 0
}
