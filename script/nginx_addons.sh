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

install_nginx_addons() {

apt-get -y --assume-yes install autoconf automake libtool >>"${main_log}" 2>>"${err_log}"


apt-get -y --assume-yes install git unzip >>"${main_log}" 2>>"${err_log}"

cd ~/sources
wget --no-check-certificate https://codeload.github.com/pagespeed/ngx_pagespeed/zip/v${NPS_VERSION}-stable >>"${main_log}" 2>>"${err_log}"
unzip v${NPS_VERSION}-stable >>"${main_log}" 2>>"${err_log}"

cd ngx_pagespeed-${NPS_VERSION}-stable/ >>"${main_log}" 2>>"${err_log}"

wget --no-check-certificate https://dl.google.com/dl/page-speed/psol/${PSOL_VERSION}-x64.tar.gz >>"${main_log}" 2>>"${err_log}"
tar -xzf ${PSOL_VERSION}-x64.tar.gz >>"${main_log}" 2>>"${err_log}"

cd ~/sources
git clone --recursive https://github.com/bagder/libbrotli >>"${main_log}" 2>>"${err_log}"
cd libbrotli
autoreconf -v -i >>"${main_log}" 2>>"${err_log}"
./autogen.sh >>"${main_log}" 2>>"${err_log}"
./configure >>"${main_log}" 2>>"${err_log}"
mkdir brotli/c/tools/.deps && touch brotli/c/tools/.deps/brotli-brotli.Po
make >>"${main_log}" 2>>"${err_log}"
make install >>"${main_log}" 2>>"${err_log}"
ldconfig

cd ~/sources
git clone https://github.com/google/ngx_brotli >>"${main_log}" 2>>"${err_log}"
cd ngx_brotli
git submodule update --init >>"${main_log}" 2>>"${err_log}"
}