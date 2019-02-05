#!/bin/bash
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

menu_options_wordpress() {

trap error_exit ERR

source ${SCRIPT_PATH}/configs/userconfig.cfg
source ${SCRIPT_PATH}/script/functions.sh; get_domain

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=3
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="In which path do you want to install Wordpress?"
OPTIONS=(1 "${MYDOMAIN}/wordpress"
2 "${MYDOMAIN}/blog"
3 "Custom (except root and minimum 2 characters!)")
menu
clear

case $CHOICE in
  1)
    WORDPRESS_PATH_NAME="wordpress"
    sed -i 's/WORDPRESS_PATH_NAME="0"/WORDPRESS_PATH_NAME="'${WORDPRESS_PATH_NAME}'"/' ${SCRIPT_PATH}/configs/userconfig.cfg
    ;;
  2)
    WORDPRESS_PATH_NAME="blog"
    sed -i 's/WORDPRESS_PATH_NAME="0"/WORDPRESS_PATH_NAME="'${WORDPRESS_PATH_NAME}'"/' ${SCRIPT_PATH}/configs/userconfig.cfg
    ;;
  3)
      while true
        do
          WORDPRESS_PATH_NAME=$(dialog --clear \
          --backtitle "$BACKTITLE" \
          --inputbox "Enter the name of Wordpress installation path. Link after ${MYDOMAIN}/ only A-Z and a-z letters \
          \n\nYour Input should have at least 2 characters or numbers!" \
          $HEIGHT $WIDTH \
          3>&1 1>&2 2>&3 3>&- \
          )
            if [[ "$WORDPRESS_PATH_NAME" =~ ^[a-zA-Z0-9]+$ ]]; then
              if [ ${#WORDPRESS_PATH_NAME} -ge 2 ]; then
                declare -a array=('webmail' 'rspamd')
                array+=(${NEXTCLOUD_PATH_NAME})
                array+=(${PHPMYADMIN_PATH_NAME})
                printf -v array_str -- ',,%q' "${array[@]}"

                if [[ "${array_str},," =~ ,,${WORDPRESS_PATH_NAME},, ]]
                then
                  dialog_msg "[ERROR] Your Wordpress path ${WORDPRESS_PATH_NAME} is already used by the script, please choose another one!"
                  dialog --clear
                else
                  sed -i 's/WORDPRESS_PATH_NAME="0"/WORDPRESS_PATH_NAME="'${WORDPRESS_PATH_NAME}'"/' ${SCRIPT_PATH}/configs/userconfig.cfg
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
