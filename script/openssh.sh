#!/bin/bash
# Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_openssh() {

mkdir -p /etc/ssh

install_packages "libpam-dev"

cd ${SCRIPT_PATH}/sources

wget_tar "https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/${OPENSSH_VERSION}.tar.gz"
tar_file "openssh-${OPENSSH_VERSION}.tar.gz"


cd openssh-${OPENSSH_VERSION}
 ./configure --prefix=/usr --with-pam --with-zlib --with-ssl-engine --with-ssl-dir=/etc/ssl --sysconfdir=/etc/ssh
make -j $(nproc) >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to make openssh"
mv /etc/ssh{,.bak}
make install >>"${main_log}" 2>>"${err_log}"

cp ${SCRIPT_PATH}/configs/sshd_config /etc/ssh/sshd_config
cp ${SCRIPT_PATH}/includes/issue /etc/issue
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

		while true
		do
		RANDOM_SSH_PORT="$(($RANDOM % 1023))"
			# Check is RANDOM_SSH_PORT known in BLOCKED_PORTS
			if [[ -v BLOCKED_PORTS[$RANDOM_SSH_PORT] ]]; then
				echo "Random Openssh Port is used by the system, creating new one"
			else
				SSH_PORT="$RANDOM_SSH_PORT"
				break
			fi
		done

sed -i "s/^Port 22/Port $SSH_PORT/g" /etc/ssh/sshd_config

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "#SSH_PORT: ${SSH_PORT}" >> ${SCRIPT_PATH}/login_information.txt
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt

SSH_PASS=$(password)

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "#SSH_PASS: ${SSH_PASS}" >> ${SCRIPT_PATH}/login_information.txt
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt

ssh-keygen -f ~/ssh.key -t ed25519 -N ${SSH_PASS} >>"${main_log}" 2>>"${err_log}"
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
