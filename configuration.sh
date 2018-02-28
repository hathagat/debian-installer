#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script! 
#-------------------------------------------------------------------------------------------------------------

HEIGHT=30
WIDTH=60

show_ssh_key()
{
dialog --backtitle "NeXt Server Configuration" --msgbox "Please save the shown SSH privatekey into a textfile on your PC." $HEIGHT $WIDTH
cat ${SCRIPT_PATH}/ssh_privatekey.txt
}

show_login_information()
{
dialog --backtitle "NeXt Server Configuration" --msgbox "Please save the shown login information" $HEIGHT $WIDTH
cat ${SCRIPT_PATH}/login_information
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
dialog --backtitle "NeXt Server Configuration" --msgbox "Please enter the shown DKIM key to you DNS settings \n\n
remove all quote signs - so it looks like that:  \n\n
v=DKIM1; k=rsa; p=MIIBIjANBgkqh[...] "$HEIGHT $WIDTH
cat ${SCRIPT_PATH}/DKIM_KEY_ADD_TO_DNS.txt
}
