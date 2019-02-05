#!/bin/bash
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

menu_options_nextcloud() {

source ${SCRIPT_PATH}/configs/userconfig.cfg
source ${SCRIPT_PATH}/script/functions.sh; get_domain

trap error_exit ERR

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=3
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="In which path do you want to install Nextcloud?"
OPTIONS=(1 "${MYDOMAIN}/nextcloud"
2 "${MYDOMAIN}/cloud"
3 "Custom (except root and minimum 2 characters!)")
menu
clear

case $CHOICE in
  1)
    NEXTCLOUD_PATH_NAME="nextcloud"
    sed -i 's/NEXTCLOUD_PATH_NAME="0"/NEXTCLOUD_PATH_NAME="'${NEXTCLOUD_PATH_NAME}'"/' ${SCRIPT_PATH}/configs/userconfig.cfg
    ;;
  2)
    NEXTCLOUD_PATH_NAME="cloud"
    sed -i 's/NEXTCLOUD_PATH_NAME="0"/NEXTCLOUD_PATH_NAME="'${NEXTCLOUD_PATH_NAME}'"/' ${SCRIPT_PATH}/configs/userconfig.cfg
    ;;
  3)
      while true
        do
          NEXTCLOUD_PATH_NAME=$(dialog --clear \
          --backtitle "$BACKTITLE" \
          --inputbox "Enter the name of Nextcloud installation path. Link after ${MYDOMAIN}/ only A-Z and a-z letters \
          \n\nYour Input should have at least 2 characters or numbers!" \
          $HEIGHT $WIDTH \
          3>&1 1>&2 2>&3 3>&- \
          )
            if [[ "$NEXTCLOUD_PATH_NAME" =~ ^[a-zA-Z0-9]+$ ]]; then
              if [ ${#NEXTCLOUD_PATH_NAME} -ge 2 ]; then
                declare -a array=('webmail' 'rspamd')
                array+=(${WORDPRESS_PATH_NAME})
                array+=(${PHPMYADMIN_PATH_NAME})
                printf -v array_str -- ',,%q' "${array[@]}"

                if [[ "${array_str},," =~ ,,${NEXTCLOUD_PATH_NAME},, ]]
                then
                  dialog_msg "[ERROR] Your Nextcloud path ${NEXTCLOUD_PATH_NAME} is already used by the script, please choose another one!"
                  dialog --clear
                else
                  sed -i 's/NEXTCLOUD_PATH_NAME="0"/NEXTCLOUD_PATH_NAME="'${NEXTCLOUD_PATH_NAME}'"/' ${SCRIPT_PATH}/configs/userconfig.cfg
                  break
                fi
              else
                dialog_msg "[ERROR] Your Input should have at least 2 characters or numbers!"
                dialog --clear
              fi
            else
              dialog_msg "[ERROR] Your Input should contain characters or numbers!!"
              dialog --clear
            fi
        done
    ;;
esac
}
