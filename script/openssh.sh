#!/bin/bash

install_openssh() {

install_packages "openssh-server openssh-client libpam-dev"

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

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "#SSH_PORT: ${SSH_PORT}" >> ${SCRIPT_PATH}/login_information.txt
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt

SSH_PASS=$(password)

if [ -z "${SSH_PASS}" ]; then
    echo "SSH_PASS is unset or set to the empty string, creating new one!"
    SSH_PASS=$(password)
fi

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "#SSH_PASS: ${SSH_PASS}" >> ${SCRIPT_PATH}/login_information.txt
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt

ssh-keygen -f ~/ssh.key -t ed25519 -N ${SSH_PASS} >>"${main_log}" 2>>"${err_log}"
mkdir -p ~/.ssh && chmod 700 ~/.ssh
cat ~/ssh.key.pub > ~/.ssh/authorized_keys2 && rm ~/ssh.key.pub
chmod 600 ~/.ssh/authorized_keys2
mv ~/ssh.key ${SCRIPT_PATH}/ssh_privatekey.txt

groupadd --system -g ${SSH_PORT} sshusers >>"${main_log}" 2>>"${err_log}"
adduser ${LOGIN_USER} --gecos "" --disabled-password --no-create-home --home /root/ --shell /bin/sh -u ${SSH_PORT} --ingroup sshusers >>"${main_log}" 2>>"${err_log}"
usermod -a -G sshusers ${LOGIN_USER} >>"${main_log}" 2>>"${err_log}"

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "#LOGIN_USER: ${LOGIN_USER}" >> ${SCRIPT_PATH}/login_information
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt

truncate -s 0 /var/log/daemon.log
truncate -s 0 /var/log/syslog

service sshd restart
}
