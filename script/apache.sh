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

install_apache() {

mkdir -p ~/sources/

#installing apr
cd ~/sources
wget -c4 --no-check-certificate http://ftp-stud.hs-esslingen.de/pub/Mirrors/ftp.apache.org/dist//apr/apr-${APR_VERSION}.tar.gz --tries=3
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: apr-${APR_VERSION}.tar.gz download failed."
      exit
    fi

tar -xzf apr-${APR_VERSION}.tar.gz
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: httpd-${APR_VERSION}.tar.gz is corrupted."
      exit
    fi
rm apr-${APR_VERSION}.tar.gz	
	
cd apr-${APR_VERSION}
sed -i 's/\$RM "\$cfgfile"/\$RM  -f  “\$cfgfile”/' configure
./configure --prefix=/usr/local/apr/
make -j $(nproc) >>"$make_log" 2>>"$make_err_log"
make install

#apr-util
cd ~/sources
wget http://ftp.halifax.rwth-aachen.de/apache//apr/apr-util-${APR_UTIL_VERSION}.tar.bz2
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: apr-util-${APR_VERSION}.tar.gz download failed."
      exit
    fi
	
tar -xvjf apr-util-${APR_UTIL_VERSION}.tar.bz2
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: httpd-${APR_VERSION}.tar.gz is corrupted."
      exit
    fi

cd apr-util-${APR_UTIL_VERSION}
./configure --prefix=/usr/local/apr/ --with-apr=/usr/local/apr/
make -j $(nproc) >>"$make_log" 2>>"$make_err_log"
make install

#installing apache
cd ~/sources
wget -c4 --no-check-certificate http://mirror.dkd.de/apache//httpd/httpd-${APACHE_VERSION}.tar.gz --tries=3
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: httpd-${APACHE_VERSION}.tar.gz download failed."
      exit
    fi

tar -xzf httpd-${APACHE_VERSION}.tar.gz
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: httpd-${APACHE_VERSION}.tar.gz is corrupted."
      exit
    fi
rm httpd-${APACHE_VERSION}.tar.gz	
	
cd httpd-${APACHE_VERSION}
