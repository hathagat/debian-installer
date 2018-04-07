#!/bin/bash

add_openssh_user() {

#NEW_OPENSSH_USER
apt-get update
#usermod -a -G ssh-user root

}

change_openssh_port() {

sed -i "s/^Port .*/Port $NEW_SSH_PORT/g" /etc/ssh/sshd_config

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "#NEW_SSH_PORT: $NEW_SSH_PORT" >> ${SCRIPT_PATH}/login_information.txt
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt

service sshd restart
}

create_new_openssh_key() {

rm -rf ~/.ssh/*
rm ${SCRIPT_PATH}/ssh_privatekey.txt

NEW_SSH_PASS=$(password)
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "#NEW_SSH_PASS: $NEW_SSH_PASS" >> ${SCRIPT_PATH}/login_information.txt
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt

ssh-keygen -f ~/ssh.key -t ed25519 -N $NEW_SSH_PASS >>"${main_log}" 2>>"${err_log}"
mkdir -p ~/.ssh && chmod 700 ~/.ssh
cat ~/ssh.key.pub > ~/.ssh/authorized_keys2 && rm ~/ssh.key.pub
chmod 600 ~/.ssh/authorized_keys2
mv ~/ssh.key ${SCRIPT_PATH}/ssh_privatekey.txt

service sshd restart
}
