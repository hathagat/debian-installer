#!/bin/bash

HEIGHT=40
WIDTH=80

show_ssh_key()
{
dialog --backtitle "NeXt Server Configuration" --msgbox "Please save the shown SSH privatekey on next page into a textfile on your PC. \n\n
Important: \n
In Putty you have only mark the text. Do not Press STRG+C!" $HEIGHT $WIDTH
#dialog --title "Your SSH Privatekey" --tab-correct --exit-label "ok" --textbox ${SCRIPT_PATH}/ssh_privatekey.txt 50 200
cat ${SCRIPT_PATH}/ssh_privatekey.txt
}

show_login_information.txt()
{
dialog_msg "Please save the shown login information on next page"
#dialog --title "Your Server Logininformations" --tab-correct --exit-label "ok" --textbox ${SCRIPT_PATH}/login_information.txt 50 200
cat ${SCRIPT_PATH}/login_information.txt
}

create_private_key()
{
dialog --backtitle "NeXt Server Configuration" --msgbox "You have to download the latest PuTTYgen \n (https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) \n \n
Start the program and click on Conversions- Import key. \n
Now select the Text file, where you saved the ssh_privatekey. \n
After entering your SSH Password, you have to switch the paramter from RSA to ED25519. \n
In the last step click on save private key - done! \n \n
Dont forget to change your SSH Port in PuTTY!" $HEIGHT $WIDTH
}

show_dkim_key()
{
dialog --backtitle "NeXt Server Configuration" --msgbox "Please enter the shown DKIM key on next page to you DNS settings \n\n
remove all quote signs - so it looks like that:  \n\n
v=DKIM1; k=rsa; p=MIIBIjANBgkqh[...] "$HEIGHT $WIDTH
#dialog --title "Your Server Logininformations" --tab-correct  --exit-label "ok"--textbox ${SCRIPT_PATH}/DKIM_KEY_ADD_TO_DNS.txt 50 200
cat ${SCRIPT_PATH}/DKIM_KEY_ADD_TO_DNS.txt
}
