#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#
	# This program is free software; you can redistribute it and/or modify
    # it under the terms of the GNU General Public License as published by
    # the Free Software Foundation; either version 2 of the License, or
    # (at your option) any later version.

    # This program is distributed in the hope that it will be useful,
    # but WITHOUT ANY WARRANTY; without even the implied warranty of
    # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    # GNU General Public License for more details.

    # You should have received a copy of the GNU General Public License along
    # with this program; if not, write to the Free Software Foundation, Inc.,
    # 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#-------------------------------------------------------------------------------------------------------------

error_exit() {

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

				#Get OS
				USED_OS=$(lsb_release -is)

				sed -i "s/${MYDOMAIN}/domain.tld/g" /root/logs/main.log
				sed -i "s/${LOGIN_DATA_MAIL_PW}/LOGIN_DATA_MAIL_PW/g" /root/logs/main.log
				sed -i "s/${SSH_PASS}/SSH_PASS/g" /root/logs/main.log
				sed -i "s/${POSTFIX_ADMIN_PASS}/POSTFIX_ADMIN_PASS/g" /root/logs/main.log
				sed -i "s/${VIMB_MYSQL_PASS}/VIMB_MYSQL_PASS/g" /root/logs/main.log
				sed -i "s/${ROUNDCUBE_MYSQL_PASS}/ROUNDCUBE_MYSQL_PASS/g" /root/logs/main.log
				sed -i "s/${PMA_HTTPAUTH_PASS}/PMA_HTTPAUTH_PASS/g" /root/logs/main.log
				sed -i "s/${PMA_BFSECURE_PASS}/PMA_BFSECURE_PASS/g" /root/logs/main.log
				sed -i "s/${MYSQL_ROOT_PASS}/MYSQL_ROOT_PASS/g" /root/logs/main.log
				sed -i "s/${MYSQL_PMADB_PASS}/MYSQL_PMADB_PASS/g" /root/logs/main.log

				sed -i "s/${MYDOMAIN}/domain.tld/g" /root/logs/error.log
				sed -i "s/${LOGIN_DATA_MAIL_PW}/LOGIN_DATA_MAIL_PW/g" /root/logs/error.log
				sed -i "s/${SSH_PASS}/SSH_PASS/g" /root/logs/error.log
				sed -i "s/${POSTFIX_ADMIN_PASS}/POSTFIX_ADMIN_PASS/g" /root/logs/error.log
				sed -i "s/${VIMB_MYSQL_PASS}/VIMB_MYSQL_PASS/g" /root/logs/error.log
				sed -i "s/${ROUNDCUBE_MYSQL_PASS}/ROUNDCUBE_MYSQL_PASS/g" /root/logs/error.log
				sed -i "s/${PMA_HTTPAUTH_PASS}/PMA_HTTPAUTH_PASS/g" /root/logs/error.log
				sed -i "s/${PMA_BFSECURE_PASS}/PMA_BFSECURE_PASS/g" /root/logs/error.log
				sed -i "s/${MYSQL_ROOT_PASS}/MYSQL_ROOT_PASS/g" /root/logs/error.log
				sed -i "s/${MYSQL_PMADB_PASS}/MYSQL_PMADB_PASS/g" /root/logs/error.log

				sed -i '/MYDOMAIN=/d' /root/configs/userconfig.cfg
				sed -i '/SSLMAIL=/d' /root/configs/userconfig.cfg
				sed -i '/LOGIN_DATA_MAIL_PW=/d' /root/configs/userconfig.cfg
				sed -i '/SSH_PASS=/d' /root/configs/userconfig.cfg
				sed -i '/POSTFIX_ADMIN_PASS=/d' /root/configs/userconfig.cfg
				sed -i '/VIMB_MYSQL_PASS=/d' /root/configs/userconfig.cfg
				sed -i '/ROUNDCUBE_MYSQL_PASS=/d' /root/configs/userconfig.cfg
				sed -i '/PMA_HTTPAUTH_PASS=/d' /root/configs/userconfig.cfg
				sed -i '/PMA_BFSECURE_PASS=/d' /root/configs/userconfig.cfg
				sed -i '/MYSQL_ROOT_PASS=/d' /root/configs/userconfig.cfg
				sed -i '/MYSQL_PMADB_PASS=/d' /root/configs/userconfig.cfg

				echo -e "##-----------------------------------------------##" >> /root/configs/userconfig.cfg
				echo -e "##----------From Error reporting System----------##" >> /root/configs/userconfig.cfg
				echo -e "##----------The file has been anonymized!--------##" >> /root/configs/userconfig.cfg
				echo -e "##-----------------------------------------------##" >> /root/configs/userconfig.cfg

				echo -e "##-----------------------------------------------##" >> /root/logs/main.log
				echo -e "##----------From Error reporting System----------##" >> /root/logs/main.log
				echo -e "##----------The file has been anonymized!--------##" >> /root/logs/main.log
				echo -e "##-----------------------------------------------##" >> /root/logs/main.log

				echo -e "##-----------------------------------------------##" >> /root/logs/error.log
				echo -e "##----------From Error reporting System----------##" >> /root/logs/error.log
				echo -e "##----------The file has been anonymized!--------##" >> /root/logs/error.log
				echo -e "##-----------------------------------------------##" >> /root/logs/error.log

				#PGP issue
				echo "Here are the error Logs from failed installation ( $USED_OS ) of NeXt Server script. Error: $1" | mutt -a "/root/logs/main.log" "/root/logs/error.log" "/root/logs/make.log" "/root/logs/make_error.log" "/root/configs/userconfig.cfg" "/root/logs/addons_error.log" -s "FAILED INSTALLATION OF PERFECT ROOTSERVER" -- error@perfectrootserver.de >/dev/null 2>&1

				HEIGHT=15
				WIDTH=70
				dialog --backtitle "NeXt Server Installation" --msgbox "Thank you for the Bug Report! Error: $1" $HEIGHT $WIDTH
				clear
				exit 1
				;;
			2)
				echo "Please post the following Error at https://perfectrootserver.de/ to get help. Error: $1"
				exit 1
				;;
	esac
}
