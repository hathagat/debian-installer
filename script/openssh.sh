#!/bin/bash

install_openssh() {

trap error_exit ERR

mkdir -p /etc/ssh
install_packages "openssh-server"

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
    [1001]="1"
    [4000]="1")'

if [[ "$FIX_SSH_PORT" == "1" ]] && ! [[ -v BLOCKED_PORTS[$FIXED_SSH_PORT] ]]; then
    SSH_PORT=${FIXED_SSH_PORT}
else
	while true
	do
	    RANDOM_SSH_PORT="$(($RANDOM % 1023))"
		if [[ -v BLOCKED_PORTS[$RANDOM_SSH_PORT] ]]; then
			echo "Random Openssh port is already in use, creating new one..."
		else
			SSH_PORT="$RANDOM_SSH_PORT"
			break
		fi
	done
fi

echo "SSH_PORT:   ${SSH_PORT}" >> ${SCRIPT_PATH}/login_information.txt

sed -i "s/^Port 22/Port $SSH_PORT/g" /etc/ssh/sshd_config
sed -i "s/^Match User sshuser/Match User $LOGIN_USER/g" /etc/ssh/sshd_config

SSH_PASS=$(password)
SSH_GROUP="sshusers"

echo "SSH_PASS:   ${SSH_PASS}" >> ${SCRIPT_PATH}/login_information.txt

getent group ${SSH_GROUP} >>/dev/null || groupadd --system -g ${SSH_PORT} ${SSH_GROUP} >>"${main_log}" 2>>"${err_log}"

if [[ ${LOGIN_USER} == "root" ]]; then
    sed -i "s/^PermitRootLogin no/PermitRootLogin without-password/g" /etc/ssh/sshd_config
else
    adduser ${LOGIN_USER} --gecos "" --disabled-password --no-create-home --home / --shell /bin/sh -u ${SSH_PORT} --ingroup ${SSH_GROUP} >>"${main_log}" 2>>"${err_log}"
fi
usermod -a -G ${SSH_GROUP} ${LOGIN_USER} >>"${main_log}" 2>>"${err_log}"

echo "LOGIN_USER: ${LOGIN_USER}" >> ${SCRIPT_PATH}/login_information.txt

ssh-keygen -f ~/ssh.key -t ed25519 -N ${SSH_PASS} -C "" >>"${main_log}" 2>>"${err_log}"
cat ~/ssh.key.pub > /etc/ssh/.authorized_keys && rm ~/ssh.key.pub
chmod 600 /etc/ssh/.authorized_keys
chown ${LOGIN_USER}:${SSH_GROUP} /etc/ssh/.authorized_keys
mv ~/ssh.key ${SCRIPT_PATH}/ssh_privatekey.txt

truncate -s 0 /var/log/daemon.log
truncate -s 0 /var/log/syslog

service sshd restart
}
