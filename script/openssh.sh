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

menu_options_openssh() {

HEIGHT=30
WIDTH=60
CHOICE_HEIGHT=6
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

	OPTIONS=(1 "Install Openssh"
			 2 "Update Openssh"
			 3 "Change Openssh Port"
			 4 "Create new Openssh Key"
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
				dialog --backtitle "NeXt Server Installation" --infobox "Installing Openssh" $HEIGHT $WIDTH
				source /root/script/logs.sh; set_logs
				source /root/script/prerequisites.sh; prerequisites
				install_openssh
				dialog --backtitle "NeXt Server Installation" --msgbox "Finished installing Openssh" $HEIGHT $WIDTH
				echo
				echo
				echo "You can find your SSH key at /root/ssh_privatekey.txt"
				echo
				echo
				echo "Password for your ssh key = $SSH_PASS"
				echo
				echo
				echo "Your SSH Key"
				cat ~/ssh_privatekey.txt
				echo "You can also find your SSH key at /root/ssh_privatekey.txt"
				exit 1
				;;
			2)
				dialog --backtitle "NeXt Server Installation" --infobox "Updating Openssh" $HEIGHT $WIDTH
				source /root/script/logs.sh; set_logs
				source /root/script/prerequisites.sh; prerequisites
				update_openssh
				dialog --backtitle "NeXt Server Installation" --msgbox "Finished updating Openssh" $HEIGHT $WIDTH
				;;
			3)
			while true
				do
					INPUT_NEW_SSH_PORT=$(dialog --clear \
							--backtitle "$BACKTITLE" \
							--inputbox "Enter your SSH Port (only max. 3 numbers!):" \
							$HEIGHT $WIDTH \
							3>&1 1>&2 2>&3 3>&- \
							)
					if [[ $INPUT_NEW_SSH_PORT =~ ^-?[0-9]+$ ]]; then
						if [[ -v BLOCKED_PORTS[$INPUT_NEW_SSH_PORT] ]]; then
							dialog --title "NeXt Server Confighelper" --msgbox "$INPUT_NEW_SSH_PORT is known. Choose an other Port!" $HEIGHT $WIDTH
							dialog --clear
						else
							NEW_SSH_PORT="$INPUT_NEW_SSH_PORT"
							echo " you port is $NEW_SSH_PORT"
							break
						fi
					else
					dialog --title "NeXt Server Confighelper" --msgbox "The Port should only contain numbers!" $HEIGHT $WIDTH
					dialog --clear
					fi
				done
				change_openssh_port
				dialog --backtitle "NeXt Server installation!" --infobox "Changed SSH Port to $NEW_SSH_PORT" $HEIGHT $WIDTH
				;;
			4)
				dialog --backtitle "NeXt Server Installation" --infobox "Creating new Openssh key" $HEIGHT $WIDTH
				source /root/script/logs.sh; set_logs
				create_new_openssh_key
				dialog --backtitle "NeXt Server Installation" --msgbox "Finished creating new ssh key" $HEIGHT $WIDTH
				echo
				echo
				echo "You can find your New SSH key at /root/ssh_privatekey.txt"
				echo
				echo
				echo "Password for your  new ssh key = $SSH_PASS"
				echo
				echo
				echo "Your new SSH Key"
				cat ~/ssh_privatekey.txt
				echo "You can also find your new SSH key at /root/ssh_privatekey.txt"
				exit 1
				;;
			5)
				bash /root/start.sh;
				;;
			6)
				echo "Exit"
				exit 1
				;;
	esac
}

install_openssh() {

apt-get -y --assume-yes install openssh-server openssh-client libpam-dev >>"${main_log}" 2>>"${err_log}"

cp ~/configs/sshd_config /etc/ssh/sshd_config
cp ~/includes/issue /etc/issue

SSH_PASS=$(password)
echo  "Openssh password: $SSH_PASS" >> /root/login_information

ssh-keygen -f ~/ssh.key -t ed25519 -N $SSH_PASS >>"${main_log}" 2>>"${err_log}"
mkdir -p ~/.ssh && chmod 700 ~/.ssh
cat ~/ssh.key.pub > ~/.ssh/authorized_keys2 && rm ~/ssh.key.pub
chmod 600 ~/.ssh/authorized_keys2
mv ~/ssh.key ~/ssh_privatekey.txt

groupadd ssh-user
usermod -a -G ssh-user root

truncate -s 0 /var/log/daemon.log
truncate -s 0 /var/log/syslog

service sshd restart
}

update_openssh() {

source configs/versions.cfg

LOCAL_OPENSSH_VERSION_STRING=$(ssh -V 2>&1)
LOCAL_OPENSSH_VERSION=$(echo $LOCAL_OPENSSH_VERSION_STRING | cut -c9-13)

if [[ ${LOCAL_OPENSSH_VERSION} != ${OPENSSH_VERSION} ]]; then
	#Im moment Platzhalter, bis wir Openssh selbst kompilieren
	apt-get update
	apt-get -y --assume-yes install openssh-server openssh-client libpam-dev
else
	HEIGHT=10
	WIDTH=70
	dialog --backtitle "NeXt Server installation!" --infobox "No Openssh Update needed! Local Openssh Version: ${LOCAL_OPENSSH_VERSION}. Version to be installed: ${OPENSSH_VERSION}" $HEIGHT $WIDTH
	exit 1
fi
}

change_openssh_port() {

sed -i "s/^Port .*/Port $NEW_SSH_PORT/g" /etc/ssh/sshd_config
echo  "New Openssh Port: $NEW_SSH_PORT" >> /root/login_information

service sshd restart
}

create_new_openssh_key() {

BACKTITLE="NeXt Server Installation"
TITLE="NeXt Server Installation"
HEIGHT=30
WIDTH=60

NEW_SSH_PW=$(dialog --clear \
					--backtitle "$BACKTITLE" \
					--inputbox "Enter your new SSH password:" \
					$HEIGHT $WIDTH \
					3>&1 1>&2 2>&3 3>&- \
					)

SSH_PASS="$NEW_SSH_PW"

rm -rf ~/.ssh/*

SSH_PASS=$(password)
echo  "New Openssh password: $SSH_PASS" >> /root/login_information

ssh-keygen -f ~/ssh.key -t ed25519 -N $SSH_PASS >>"${main_log}" 2>>"${err_log}"
mkdir -p ~/.ssh && chmod 700 ~/.ssh
cat ~/ssh.key.pub > ~/.ssh/authorized_keys2 && rm ~/ssh.key.pub
chmod 600 ~/.ssh/authorized_keys2
mv ~/ssh.key ~/ssh_privatekey.txt

service sshd restart

}
