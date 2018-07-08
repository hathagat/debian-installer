#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

menu_options_wordpress() {

# --- MYDOMAIN ---
source ${SCRIPT_PATH}/script/functions.sh; get_domain

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=5
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
CHOICE_HEIGHT=4
MENU="In which path do you want to install Wordpress?"
OPTIONS=(1 "${MYDOMAIN}/wordpress"
2 "${MYDOMAIN}/blog"
3 "root of ${MYDOMAIN} DISABLED! would be ${MYDOMAIN}/blog"
4 "custom")
menu
clear

case $CHOICE in
  1)
    WORDPRESSPATHNAME="wordpress"
    ;;
  2)
    WORDPRESSPATHNAME="blog"
    ;;
  3)
    #WORDPRESSPATHNAME=""
    WORDPRESSPATHNAME="blog"
    #WORDPRESSPATHNAME="rootpath"
    ;;
  4)
      while true
        do
          WORDPRESSPATHNAME=$(dialog --clear \
          --backtitle "$BACKTITLE" \
          --inputbox "Enter the name of Wordpress installation path. Link after ${MYDOMAIN}/ only A-Z and a-z letters" \
          $HEIGHT $WIDTH \
          3>&1 1>&2 2>&3 3>&- \
          )
            if [[ "$WORDPRESSPATHNAME" =~ [^0-9A-Za-z]+ ]];then
              break
            else
              dialog_msg "[ERROR] You should read it properly!"
              dialog --clear
            fi
        done
    ;;
esac
}
