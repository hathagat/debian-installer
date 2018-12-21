#!/bin/bash

add_openssh_user() {

apt-get update
#usermod -a -G ssh-user root

}

change_openssh_port() {
##add check if port is used otherwise!
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

show_ssh_key() {
dialog_msg "Please save the shown SSH privatekey on next page into a textfile on your PC. \n\n
Important: \n
In Putty you have only mark the text. Do not Press STRG+C!"
cat ${SCRIPT_PATH}/ssh_privatekey.txt
}

create_private_key() {
dialog_msg "You have to download the latest PuTTYgen \n (https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) \n \n
Start the program and click on Conversions- Import key. \n
Now select the Text file, where you saved the ssh_privatekey. \n
After entering your SSH Password, you have to switch the paramter from RSA to ED25519. \n
In the last step click on save private key - done! \n \n
Dont forget to change your SSH Port in PuTTY!"
}
