#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

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
IPADR=$(ip route get 1.1.1.1 | awk '/1.1.1.1/ {print $(NF)}')
IPADRV6=$(ip r get 2606:4700:4700::1111 | awk '/2606:4700:4700::1111/ {print $(NF-8)}')
INTERFACE=$(ip route get 1.1.1.1 | head -1 | cut -d' ' -f5)
FQDNIP=$(dig @1.1.1.1 +short ${MYDOMAIN})
WWWIP=$(dig @1.1.1.1 +short www.${MYDOMAIN})
CHECKRDNS=$(dig @1.1.1.1 -x ${IPADR} +short)
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
dialog --backtitle "NeXt Server Installation" --infobox "$1" 40 80
}

function dialog_msg() {
dialog --backtitle "NeXt Server Installation" --msgbox "$1" 40 80
}

function dialog_yesno_configuration() {
dialog --backtitle "NeXt Server Installation" \
--yesno "Continue with NeXt Server Configuration?" 7 60

CHOICE=$?
case $CHOICE in
   1)
        echo "Skipped the NeXt Server Configuration!"
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
DEBIAN_FRONTEND=noninteractive apt-get -y --allow-unauthenticated install $1 >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install $1 packages"
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
  echo "Visit https://github.com/shoujii/NeXt-Server/issues/new to add the Issue on Github!"
  echo "Your Issue is: $1"
  echo "Your used OS is: $USED_OS"
	exit 1
}

show_login_information()
{
  dialog_msg "Please save the shown login information on next page"
  cat ${SCRIPT_PATH}/login_information.txt
  fi
}
