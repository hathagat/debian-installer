#!/bin/bash

install_openssh() {

apt-get -y --assume-yes install openssh-server openssh-client libpam-dev >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install openssh packages"

cp ${SCRIPT_PATH}/configs/sshd_config /etc/ssh/sshd_config
cp ${SCRIPT_PATH}/includes/issue.net /etc/issue
cp ${SCRIPT_PATH}/includes/issue.net /etc/issue.net

declare -A BLOCKED_PORTS='(
    [22]="1"
    [25]="1"
    [80]="1"
    [110]="1"
    [143]="1"
    [443]="1"
    [465]="1"
    [587]="1"
    [993]="1"
    [995]="1"
    [1000]="1"
    [4000]="1")'

if [ "$FIX_SSH_PORT" == "1" ] && ! [ -v BLOCKED_PORTS[$FIXED_SSH_PORT] ]; then
    SSH_PORT=${FIXED_SSH_PORT}
else
	while true
	do
	    RANDOM_SSH_PORT="$(($RANDOM % 1023))"
		if [[ -v BLOCKED_PORTS[$RANDOM_SSH_PORT] ]]; then
			echo "Random Openssh Port is used by the system, creating new one"
		else
			SSH_PORT="$RANDOM_SSH_PORT"
			break
		fi
	done
fi

sed -i "s/^Port 22/Port $SSH_PORT/g" /etc/ssh/sshd_config

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "#SSH_PORT: ${SSH_PORT}" >> ${SCRIPT_PATH}/login_information
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information

SSH_PASS=$(password)

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "#SSH_PASS: ${SSH_PASS}" >> ${SCRIPT_PATH}/login_information
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information

ssh-keygen -f ~/ssh.key -t ed25519 -N ${SSH_PASS} >>"${main_log}" 2>>"${err_log}"
mkdir -p ~/.ssh && chmod 700 ~/.ssh
cat ~/ssh.key.pub > ~/.ssh/authorized_keys2 && rm ~/ssh.key.pub
chmod 600 ~/.ssh/authorized_keys2
mv ~/ssh.key ${SCRIPT_PATH}/ssh_privatekey.txt

groupadd --system -g ${SSH_PORT} sshusers >>"${main_log}" 2>>"${err_log}"
adduser ${LOGIN_USER} --gecos "" --disabled-password --no-create-home --home /root/ --shell /bin/sh -u ${SSH_PORT} --ingroup sshusers >>"${main_log}" 2>>"${err_log}"
usermod -a -G sshusers ${LOGIN_USER} >>"${main_log}" 2>>"${err_log}"

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "#LOGIN_USER: ${LOGIN_USER}" >> ${SCRIPT_PATH}/login_information
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information

truncate -s 0 /var/log/daemon.log
truncate -s 0 /var/log/syslog

service sshd restart
}

update_openssh() {

source ${SCRIPT_PATH}/configs/versions.cfg

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
echo "#NEW_SSH_PORT: $NEW_SSH_PORT" >> ${SCRIPT_PATH}/login_information
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information

service sshd restart
}

create_new_openssh_key() {

rm -rf ~/.ssh/*
rm ${SCRIPT_PATH}/ssh_privatekey.txt

NEW_SSH_PASS=$(password)
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "#NEW_SSH_PASS: $NEW_SSH_PASS" >> ${SCRIPT_PATH}/login_information
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information

ssh-keygen -f ~/ssh.key -t ed25519 -N $NEW_SSH_PASS >>"${main_log}" 2>>"${err_log}"
mkdir -p ~/.ssh && chmod 700 ~/.ssh
cat ~/ssh.key.pub > ~/.ssh/authorized_keys2 && rm ~/ssh.key.pub
chmod 600 ~/.ssh/authorized_keys2
mv ~/ssh.key ${SCRIPT_PATH}/ssh_privatekey.txt

service sshd restart
}
