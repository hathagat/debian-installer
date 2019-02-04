#!/bin/bash
# Compatible with Debian 10.x Buster
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

menu_options_phpmyadmin() {

source ${SCRIPT_PATH}/configs/userconfig.cfg
source ${SCRIPT_PATH}/script/functions.sh; get_domain

trap error_exit ERR

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=3
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="In which path do you want to install Phpmyadmin?"
OPTIONS=(1 "${MYDOMAIN}/pma"
2 "${MYDOMAIN}/phpmyadmin"
3 "Custom (except root and minimum 2 characters!)")
menu
clear

case $CHOICE in
  1)
    PHPMYADMIN_PATH_NAME="pma"
    sed -i 's/PHPMYADMIN_PATH_NAME="0"/PHPMYADMIN_PATH_NAME="'${PHPMYADMIN_PATH_NAME}'"/' ${SCRIPT_PATH}/configs/userconfig.cfg
    ;;
  2)
    PHPMYADMIN_PATH_NAME="phpmyadmin"
    sed -i 's/PHPMYADMIN_PATH_NAME="0"/PHPMYADMIN_PATH_NAME="'${PHPMYADMIN_PATH_NAME}'"/' ${SCRIPT_PATH}/configs/userconfig.cfg
    ;;
  3)
      while true
        do
          PHPMYADMIN_PATH_NAME=$(dialog --clear \
          --backtitle "$BACKTITLE" \
          --inputbox "Enter the name of Phpmyadmin installation path. Link after ${MYDOMAIN}/ only A-Z and a-z letters \
          \n\nYour Input should have at least 2 characters or numbers!" \
          $HEIGHT $WIDTH \
          3>&1 1>&2 2>&3 3>&- \
          )
            if [[ "$PHPMYADMIN_PATH_NAME" =~ ^[a-zA-Z0-9]+$ ]]; then
              if [ ${#PHPMYADMIN_PATH_NAME} -ge 2 ]; then
                declare -a array=('webmail' 'rspamd')
                array+=(${WORDPRESS_PATH_NAME})
                array+=(${NEXTCLOUD_PATH_NAME})
                printf -v array_str -- ',,%q' "${array[@]}"

                if [[ "${array_str},," =~ ,,${PHPMYADMIN_PATH_NAME},, ]]
                then
                  dialog_msg "[ERROR] Your Phpmyadmin path ${PHPMYADMIN_PATH_NAME} is already used by the script, please choose another one!"
                  dialog --clear
                else
                  sed -i 's/PHPMYADMIN_PATH_NAME="0"/PHPMYADMIN_PATH_NAME="'${PHPMYADMIN_PATH_NAME}'"/' ${SCRIPT_PATH}/configs/userconfig.cfg
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
