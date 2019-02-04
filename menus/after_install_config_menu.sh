#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

menu_options_after_install() {

trap error_exit ERR  

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=6
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

    OPTIONS=(1 "Full after installation configuration"
             2 "Show SSH Key"
             3 "Show Login information"
             4 "Create private key"
             5 "Back"
             6 "Exit")

    CHOICE=$(dialog --clear \
            --nocancel \
            --no-cancel \
            --backtitle "$BACKTITLE" \
            --title "$TITLE" \
            --menu "$MENU" \
            $HEIGHT $WIDTH $CHOICE_HEIGHT \
            "${OPTIONS[@]}" \
            2>&1 >/dev/tty)

    clear
    case $CHOICE in
        1)
          source ${SCRIPT_PATH}/script/configuration.sh; start_after_install
          source ${SCRIPT_PATH}/script/functions.sh; continue_to_menu
          ;;
        2)
          source ${SCRIPT_PATH}/script/openssh_options.sh; show_ssh_key
          source ${SCRIPT_PATH}/script/functions.sh; continue_to_menu
          ;;
        3)
          source ${SCRIPT_PATH}/script/functions.sh; show_login_information
          source ${SCRIPT_PATH}/script/functions.sh; continue_to_menu
          ;;
        4)
          source ${SCRIPT_PATH}/script/openssh_options.sh; create_private_key
          source ${SCRIPT_PATH}/script/functions.sh; continue_to_menu
          ;;
        5)
          bash ${SCRIPT_PATH}/nxt.sh
          ;;
        6)
          echo "Exit"
          exit 1
          ;;
    esac
}
