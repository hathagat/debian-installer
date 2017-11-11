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

#################################
##  DO NOT MODIFY, JUST DON'T! ##
#################################

install_openssh() {

#installing ssh
apt-get -y --assume-yes install libpam-dev >>"$main_log" 2>>"$err_log"

apt-get -y --assume-yes install openssh-server openssh-client >>"$main_log" 2>>"$err_log"

cp ~/configs/sshd_config /etc/ssh/sshd_config
cp ~/includes/issue /etc/issue

ssh-keygen -f ~/ssh.key -t ed25519 -N ${SSH_PASS}
mkdir -p ~/.ssh && chmod 700 ~/.ssh
cat ~/ssh.key.pub > ~/.ssh/authorized_keys2 && rm ~/ssh.key.pub
chmod 600 ~/.ssh/authorized_keys2
mv ~/ssh.key ~/ssh_privatekey.txt

truncate -s 0 /var/log/daemon.log
truncate -s 0 /var/log/syslog

service sshd restart
}

#update_openssh() {

#updating openssh
apt-get update
apt-get -y --assume-yes install libpam-dev

mkdir -p ~/sources/update/
cd ~/sources/update/

cp /etc/ssh/sshd_config ~/sources/update/ 
cp /etc/issue ~/sources/update/ 

wget -c4 --no-check-certificate http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-${OPENSSH_VERSION}.tar.gz --tries=3 
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: Openssh ${OPENSSH_VERSION} download failed."
      exit
    fi
tar -xzf openssh-${OPENSSH_VERSION}.tar.gz	
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: openssh-${OPENSSH_VERSION}.tar.gz is corrupted."
      exit
    fi
rm openssh-${OPENSSH_VERSION}.tar.gz	
	
cd openssh-${OPENSSH_VERSION}		

#wget -c4 --no-check-certificate http://www.linuxfromscratch.org/patches/blfs/svn/openssh-7.6p1-openssl-1.1.0-1.patch --tries=3 
#	ERROR=$?
#	if [[ "$ERROR" != '0' ]]; then
 #     echo "Error: Openssl patch for Openssh download failed."
  #    exit
   # fi

#patch -Np1 -i openssh-7.6p1-openssl-1.1.0-1.patch	
	
#rm openssh-7.6p1-openssl-1.1.0-1.patch	

./configure --prefix=/usr --with-pam --with-zlib --without-openssl --sysconfdir=/etc/ssh
make -j $(nproc)

make install

cp ~/sources/update/sshd_config /etc/ssh/sshd_config
cp ~/sources/update/issue /etc/issue

cd ~/sources/update/
rm -R openssh-${OPENSSH_VERSION}

service sshd restart
}