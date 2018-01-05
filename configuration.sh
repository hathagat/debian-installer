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
