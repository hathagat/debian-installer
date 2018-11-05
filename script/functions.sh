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

# Check services and restart
# check_service "nginx"
# check_service "php5-fpm"
# if check_service "nginx"; then
#	echo "unable to restart"
#	else
#	echo "service is running"
#	fi
#function check_service1() {
#z=0
# ps auxw | grep -P '\b'$1'(?!-)\b' > /dev/null 2>&1
# if [ $? != 0 ]; then
#	# Try to restart Service
#	while [ $z -le 2 ];
#	do
#		service $1 restart > /dev/null 2>&1
#		sleep 1
#		z=$(( z+1 ))
#	done
#
# else
#   echo $1 "is running"; > /dev/null 2>&1
# fi
#}

function check_service() {
if systemctl is-active --quiet $1
then
    echo "${ok} $1 is running!"
else
    echo "${error} $1 is not running!"
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

function site_is_up() {

if curl -s --head  --request GET $1 | grep "200 OK" > /dev/null; then 
   site_is_up=1
else
   site_is_up=0
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

	CHOICE_HEIGHT=2
	MENU="Do you want to send the error report to us (main, error, make, make error and userconfig.log -> anonymized)? \n We will use the Error report to fix the Bug as soon as possible! \n (We try to anonymize as much data as possible, but we can't anonymize the Email Header with your Domain in it!)"
	OPTIONS=(1 "Yes"
			 2 "No")

	CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
				--no-cancel \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

	clear
	case $CHOICE in
			1)
				# Get Error Reporting System
				dialog --title "We prepare the error reporting system" --infobox "We install required packages for error reporting. Please be patient." $HEIGHT $WIDTH
				apt-get -y --assume-yes install mutt sendmail sendmail-bin sensible-mda >/dev/null 2>&1

				USED_OS=$(lsb_release -is)

				sed -i "s/${MYDOMAIN}/domain.tld/g" ${SCRIPT_PATH}/logs/main.log
				sed -i "s/${LOGIN_DATA_MAIL_PW}/LOGIN_DATA_MAIL_PW/g" ${SCRIPT_PATH}/logs/main.log
				sed -i "s/${SSH_PASS}/SSH_PASS/g" ${SCRIPT_PATH}/logs/main.log
				sed -i "s/${POSTFIX_ADMIN_PASS}/POSTFIX_ADMIN_PASS/g" ${SCRIPT_PATH}/logs/main.log
				sed -i "s/${ROUNDCUBE_MYSQL_PASS}/ROUNDCUBE_MYSQL_PASS/g" ${SCRIPT_PATH}/logs/main.log
				sed -i "s/${MYSQL_ROOT_PASS}/MYSQL_ROOT_PASS/g" ${SCRIPT_PATH}/logs/main.log
				sed -i "s/${MYSQL_PMADB_PASS}/MYSQL_PMADB_PASS/g" ${SCRIPT_PATH}/logs/main.log

				sed -i "s/${MYDOMAIN}/domain.tld/g" ${SCRIPT_PATH}/logs/error.log
				sed -i "s/${LOGIN_DATA_MAIL_PW}/LOGIN_DATA_MAIL_PW/g" ${SCRIPT_PATH}/logs/error.log
				sed -i "s/${SSH_PASS}/SSH_PASS/g" ${SCRIPT_PATH}/logs/error.log
				sed -i "s/${POSTFIX_ADMIN_PASS}/POSTFIX_ADMIN_PASS/g" ${SCRIPT_PATH}/logs/error.log
				sed -i "s/${ROUNDCUBE_MYSQL_PASS}/ROUNDCUBE_MYSQL_PASS/g" ${SCRIPT_PATH}/logs/error.log
				sed -i "s/${MYSQL_ROOT_PASS}/MYSQL_ROOT_PASS/g" ${SCRIPT_PATH}/logs/error.log
				sed -i "s/${MYSQL_PMADB_PASS}/MYSQL_PMADB_PASS/g" ${SCRIPT_PATH}/logs/error.log

				sed -i '/MYDOMAIN=/d' ${SCRIPT_PATH}/configs/userconfig.cfg
				sed -i '/SSLMAIL=/d' ${SCRIPT_PATH}/configs/userconfig.cfg
				sed -i '/LOGIN_DATA_MAIL_PW=/d' ${SCRIPT_PATH}/configs/userconfig.cfg
				sed -i '/SSH_PASS=/d' ${SCRIPT_PATH}/configs/userconfig.cfg
				sed -i '/POSTFIX_ADMIN_PASS=/d' ${SCRIPT_PATH}/configs/userconfig.cfg
				sed -i '/ROUNDCUBE_MYSQL_PASS=/d' ${SCRIPT_PATH}/configs/userconfig.cfg
				sed -i '/MYSQL_ROOT_PASS=/d' ${SCRIPT_PATH}/configs/userconfig.cfg
				sed -i '/MYSQL_PMADB_PASS=/d' ${SCRIPT_PATH}/configs/userconfig.cfg

				echo -e "##-----------------------------------------------##" >> ${SCRIPT_PATH}/configs/userconfig.cfg
				echo -e "##----------From Error reporting System----------##" >> ${SCRIPT_PATH}/configs/userconfig.cfg
				echo -e "##----------The file has been anonymized!--------##" >> ${SCRIPT_PATH}/configs/userconfig.cfg
				echo -e "##-----------------------------------------------##" >> ${SCRIPT_PATH}/configs/userconfig.cfg

				echo -e "##-----------------------------------------------##" >> ${SCRIPT_PATH}/logs/main.log
				echo -e "##----------From Error reporting System----------##" >> ${SCRIPT_PATH}/logs/main.log
				echo -e "##----------The file has been anonymized!--------##" >> ${SCRIPT_PATH}/logs/main.log
				echo -e "##-----------------------------------------------##" >> ${SCRIPT_PATH}/logs/main.log

				echo -e "##-----------------------------------------------##" >> ${SCRIPT_PATH}/logs/error.log
				echo -e "##----------From Error reporting System----------##" >> ${SCRIPT_PATH}/logs/error.log
				echo -e "##----------The file has been anonymized!--------##" >> ${SCRIPT_PATH}/logs/error.log
				echo -e "##-----------------------------------------------##" >> ${SCRIPT_PATH}/logs/error.log

				echo "Here are the error Logs from failed installation ( $USED_OS ) of NeXt Server Installation. Error: $1" | mutt -a "${SCRIPT_PATH}/logs/main.log" "${SCRIPT_PATH}/logs/error.log" "${SCRIPT_PATH}/logs/make.log" "${SCRIPT_PATH}/logs/make_error.log" "${SCRIPT_PATH}/configs/userconfig.cfg" -s "FAILED INSTALLATION OF NeXt Server Installation" -- error@nxt.sh >/dev/null 2>&1

				HEIGHT=40
				WIDTH=80
				dialog --backtitle "NeXt Server Installation" --msgbox "Thank you for the Bug Report! Error: $1" $HEIGHT $WIDTH
				clear
				exit 1
				;;
			2)
				echo "Please post the following Error at https://nxt.sh/ to get help. Error: $1"
        echo "Visit https://github.com/shoujii/NeXt-Server/issues/new to add the Issue on Github!!"
        echo "Your Issue is: $1"
				exit 1
				;;
	esac
}
