#!/bin/bash
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
IPADR=$(ip route get 1.1.1.1 | awk '/1.1.1.1/ {print $(NF-2)}')
IPV4GAT=$(ip route | awk '/default/ { print $3 }')
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
DEBIAN_FRONTEND=noninteractive apt-get -y install $1 >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install $1 packages"
        ERROR=$?
        if [[ "$ERROR" != '0' ]]; then
      echo "Error: $1 had an error during installation."
      exit
    fi
}

error_exit()
{
  #clear
  read line file <<<$(caller)
  echo "An error occurred in line $line of file $file:" >&2
  sed "${line}q;d" "$file" >&2
  echo ""
  USED_OS=$(lsb_release -ic)
  echo "Your used OS is: $USED_OS"
  echo ""
  echo "If you don't know how to resolve this Issue, please visit https://github.com/shoujii/NeXt-Server/issues/new to add the Issue on Github!"
  exit
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
