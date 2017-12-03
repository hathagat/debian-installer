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

install_openssh() {

#installing ssh
apt-get -y --assume-yes install openssh-server openssh-client libpam-dev >>"${main_log}" 2>>"${err_log}"

cp ~/configs/sshd_config /etc/ssh/sshd_config
cp ~/includes/issue /etc/issue

ssh-keygen -f ~/ssh.key -t ed25519 -N ${SSH_PASS} >>"${main_log}" 2>>"${err_log}"
mkdir -p ~/.ssh && chmod 700 ~/.ssh
cat ~/ssh.key.pub > ~/.ssh/authorized_keys2 && rm ~/ssh.key.pub
chmod 600 ~/.ssh/authorized_keys2
mv ~/ssh.key ~/ssh_privatekey.txt

truncate -s 0 /var/log/daemon.log
truncate -s 0 /var/log/syslog

service sshd restart

}

#update_openssh() {
#update
#}

change_openssh_port() {

#change ssh port
BACKTITLE="Perfect Root Server Installation"
TITLE="Perfect Root Server Installation"
HEIGHT=30
WIDTH=60

while true
	do
		NEW_SSH_PORT=$(dialog --clear \
				--backtitle "$BACKTITLE" \
				--inputbox "Enter your SSH Port (only max. 3 numbers!):" \
				$HEIGHT $WIDTH \
				3>&1 1>&2 2>&3 3>&- \
				)
		if [[ ${NEW_SSH_PORT} =~ ^-?[0-9]+$ ]]; then
			if [[ -v BLOCKED_PORTS[$NEW_SSH_PORT] ]]; then
				dialog --title "Perfectrootserver Confighelper" --msgbox "$NEW_SSH_PORT is known. Choose an other Port!" $HEIGHT $WIDTH
				dialog --clear
			else
				SSH_PORT="$NEW_SSH_PORT"
				echo " you port is $SSH_PORT"
				break
			fi
		else
		dialog --title "Perfectrootserver Confighelper" --msgbox "The Port should only contain numbers!" $HEIGHT $WIDTH
		dialog --clear
		fi
	done

sed -i "s/^Port .*/Port ${SSH_PORT}/g" /etc/ssh/sshd_config

service sshd restart

HEIGHT=10
WIDTH=70
dialog --backtitle "Welcome to the Perfect Rootserver installation!" --infobox "Changed SSH Port to ${SSH_PORT}" $HEIGHT $WIDTH
#maybe write to credentials?
}

create_openssh_key() {

#create ssh key
BACKTITLE="Perfect Root Server Installation"
TITLE="Perfect Root Server Installation"
HEIGHT=30
WIDTH=60

NEW_SSH_PW=$(dialog --clear \
					--backtitle "$BACKTITLE" \
					--inputbox "Enter your new SSH password:" \
					$HEIGHT $WIDTH \
					3>&1 1>&2 2>&3 3>&- \
					)

SSH_PASS="$NEW_SSH_PW"

ssh-keygen -f ~/ssh.key -t ed25519 -N ${SSH_PASS} >>"${main_log}" 2>>"${err_log}"
mkdir -p ~/.ssh && chmod 700 ~/.ssh
cat ~/ssh.key.pub > ~/.ssh/authorized_keys2 && rm ~/ssh.key.pub
chmod 600 ~/.ssh/authorized_keys2
mv ~/ssh.key ~/ssh_privatekey.txt

service sshd restart

HEIGHT=10
WIDTH=70
dialog --backtitle "Welcome to the Perfect Rootserver installation!" --infobox "Changed SSH password to ${SSH_PASS}" $HEIGHT $WIDTH
#maybe write to credentials?
}
