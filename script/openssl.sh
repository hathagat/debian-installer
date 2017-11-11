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

install_openssl() {

mkdir -p ~/sources/

apt-get install -y libtool zlib1g-dev libpcre3-dev libssl-dev libxslt1-dev libxml2-dev libgd2-xpm-dev libgeoip-dev libgoogle-perftools-dev libperl-dev >>"$main_log" 2>>"$err_log"

cd ~/sources
wget -c4 --no-check-certificate https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz --tries=3
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: openssl-${OPENSSL_VERSION}.tar.gz download failed."
      exit
    fi

tar -xzf openssl-${OPENSSL_VERSION}.tar.gz
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: openssl-${OPENSSL_VERSION}.tar.gz is corrupted."
      exit
    fi
rm openssl-${OPENSSL_VERSION}.tar.gz	
	
cd openssl-${OPENSSL_VERSION}

./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib shared zlib-dynamic >>"$make_log" 2>>"$make_err_log"
		 
make -j $(nproc) >>"$make_log" 2>>"$make_err_log"
make install

cd ~/sources/
rm -R openssl-${OPENSSL_VERSION}
}

#update_openssl() {

#updating openssl
mkdir -p ~/sources/update/

apt-get update
apt-get install -y build-essential libtool automake autoconf zlib1g-dev libpcre3-dev libssl-dev libxslt1-dev libxml2-dev libgd2-xpm-dev libgeoip-dev libgoogle-perftools-dev libperl-dev

cd ~/sources/update/
wget -c4 --no-check-certificate https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz --tries=3
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: openssl-${OPENSSL_VERSION}.tar.gz download failed."
      exit
    fi

tar -xzf openssl-${OPENSSL_VERSION}.tar.gz
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: openssl-${OPENSSL_VERSION}.tar.gz is corrupted."
      exit
    fi
rm openssl-${OPENSSL_VERSION}.tar.gz	
	
cd openssl-${OPENSSL_VERSION}

./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic
		 
make -j $(nproc) >>"$make_log" 2>>"$make_err_log"
make install

cd ~/sources/update/
rm -R openssl-${OPENSSL_VERSION}
}