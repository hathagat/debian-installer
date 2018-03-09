#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------
cd /etc/mailman
npm start 2>&1

echo "hi, im a reboot echo, thax for nothing." > /root/reboot.txt 2>&1