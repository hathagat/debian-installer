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

apt-get -y --assume-yes install openssh-server openssh-client libpam-dev >>"${main_log}" 2>>"${err_log}"

cp ${SCRIPT_PATH}/configs/sshd_config /etc/ssh/sshd_config
cp ${SCRIPT_PATH}/includes/issue /etc/issue
cp ${SCRIPT_PATH}/includes/issue.net /etc/issue.net

RANDOM_SSH_PORT="$(($RANDOM % 1023))"
SSH_PORT=$([[ ! -n "${BLOCKED_PORTS["$RANDOM_SSH_PORT"]}" ]] && printf "%s\n" "$RANDOM_SSH_PORT")
sed -i "s/^Port 22/Port $SSH_PORT/g" /etc/ssh/sshd_config

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "#Openssh Port:" >> ${SCRIPT_PATH}/login_information
echo "$SSH_PORT" >> ${SCRIPT_PATH}/login_information
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information

SSH_PASS=$(password)

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "#Openssh password:" >> ${SCRIPT_PATH}/login_information
echo "$SSH_PASS" >> ${SCRIPT_PATH}/login_information
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information

ssh-keygen -f ~/ssh.key -t ed25519 -N $SSH_PASS >>"${main_log}" 2>>"${err_log}"
mkdir -p ~/.ssh && chmod 700 ~/.ssh
cat ~/ssh.key.pub > ~/.ssh/authorized_keys2 && rm ~/ssh.key.pub
chmod 600 ~/.ssh/authorized_keys2
mv ~/ssh.key ${SCRIPT_PATH}/ssh_privatekey.txt

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
	apt-get update >/dev/null 2>&1
	apt-get -y --assume-yes install openssh-server openssh-client libpam-dev
else
	HEIGHT=10
	WIDTH=70
	dialog --backtitle "NeXt Server installation!" --infobox "No Openssh Update needed! Local Openssh Version: ${LOCAL_OPENSSH_VERSION}. Version to be installed: ${OPENSSH_VERSION}" $HEIGHT $WIDTH
	exit 1
fi
}

add_openssh_user() {

#NEW_OPENSSH_USER
apt-get update
#usermod -a -G ssh-user root

}

change_openssh_port() {

sed -i "s/^Port .*/Port $NEW_SSH_PORT/g" /etc/ssh/sshd_config

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "#New Openssh Port:																			 #" >> ${SCRIPT_PATH}/login_information
echo "$NEW_SSH_PORT																				" >> ${SCRIPT_PATH}/login_information
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information

service sshd restart
}

create_new_openssh_key() {

rm -rf ~/.ssh/*
rm ${SCRIPT_PATH}/ssh_privatekey.txt

NEW_SSH_PASS=$(password)
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "#New Openssh password:																			 #" >> ${SCRIPT_PATH}/login_information
echo "$NEW_SSH_PASS																				" >> ${SCRIPT_PATH}/login_information
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information

ssh-keygen -f ~/ssh.key -t ed25519 -N $NEW_SSH_PASS >>"${main_log}" 2>>"${err_log}"
mkdir -p ~/.ssh && chmod 700 ~/.ssh
cat ~/ssh.key.pub > ~/.ssh/authorized_keys2 && rm ~/ssh.key.pub
chmod 600 ~/.ssh/authorized_keys2
mv ~/ssh.key ${SCRIPT_PATH}/ssh_privatekey.txt

service sshd restart
}
