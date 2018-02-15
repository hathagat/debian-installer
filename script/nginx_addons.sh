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

install_nginx_addons() {

apt-get -y --assume-yes install autoconf automake libtool git unzip zlib1g-dev libpcre3 libpcre3-dev uuid-dev >>"${main_log}" 2>>"${err_log}"

cd ${SCRIPT_PATH}/sources
wget --no-check-certificate https://codeload.github.com/pagespeed/ngx_pagespeed/zip/v${NPS_VERSION} --tries=3 >>"${main_log}" 2>>"${err_log}"
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: v${NPS_VERSION} download failed."
      exit
    fi

unzip v${NPS_VERSION} >>"${main_log}" 2>>"${err_log}"
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: v${NPS_VERSION} is corrupted."
      exit
    fi

cd incubator-pagespeed-ngx-${NPS_VERSION}/ >>"${main_log}" 2>>"${err_log}"

wget --no-check-certificate https://dl.google.com/dl/page-speed/psol/${PSOL_VERSION}-x64.tar.gz --tries=3 >>"${main_log}" 2>>"${err_log}"
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: ${PSOL_VERSION}-x64.tar.gz download failed."
      exit
    fi

tar -xzf ${PSOL_VERSION}-x64.tar.gz >>"${main_log}" 2>>"${err_log}"
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: ${PSOL_VERSION}-x64.tar.gz is corrupted."
      exit
    fi
rm ${PSOL_VERSION}-x64.tar.gz

cd ${SCRIPT_PATH}/sources
git clone --recursive https://github.com/bagder/libbrotli >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to clone libbrotli"
cd libbrotli
autoreconf -v -i >>"${main_log}" 2>>"${err_log}"
./autogen.sh >>"${main_log}" 2>>"${err_log}"
./configure >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to configure libbrotli"
mkdir brotli/c/tools/.deps && touch brotli/c/tools/.deps/brotli-brotli.Po
make -j $(nproc) >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to make libbrotli"
make install >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install libbrotli"
ldconfig

cd ${SCRIPT_PATH}/sources
git clone https://github.com/google/ngx_brotli >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to clone ngx_brotli"
cd ngx_brotli
git submodule update --init >>"${main_log}" 2>>"${err_log}"


cd ${SCRIPT_PATH}/sources
wget --no-check-certificate https://codeload.github.com/openresty/headers-more-nginx-module/zip/v${NGINX_HEADER_MOD_VERSION} --tries=3 >>"${main_log}" 2>>"${err_log}"
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: v${NGINX_HEADER_MOD_VERSION} download failed."
      exit
    fi

unzip v${NGINX_HEADER_MOD_VERSION} >>"${main_log}" 2>>"${err_log}"
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: v${NGINX_HEADER_MOD_VERSION} is corrupted."
      exit
    fi
}
