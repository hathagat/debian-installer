#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_nginx_addons() {

apt-get -y --assume-yes install autoconf automake libtool git unzip zlib1g-dev libpcre3 libpcre3-dev uuid-dev >>"${main_log}" 2>>"${err_log}"

cd ${SCRIPT_PATH}/sources
wget_tar "https://codeload.github.com/pagespeed/ngx_pagespeed/zip/v${NPS_VERSION}"

unzip v${NPS_VERSION} >>"${main_log}" 2>>"${err_log}"
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: v${NPS_VERSION} is corrupted."
      exit
    fi

cd incubator-pagespeed-ngx-${NPS_VERSION}/ >>"${main_log}" 2>>"${err_log}"


wget_tar "https://dl.google.com/dl/page-speed/psol/${PSOL_VERSION}-x64.tar.gz"

tar_file "${PSOL_VERSION}-x64.tar.gz"

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
wget_tar "https://codeload.github.com/openresty/headers-more-nginx-module/zip/v${NGINX_HEADER_MOD_VERSION}"


unzip v${NGINX_HEADER_MOD_VERSION} >>"${main_log}" 2>>"${err_log}"
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: v${NGINX_HEADER_MOD_VERSION} is corrupted."
      exit
    fi
}

cd ${SCRIPT_PATH}/sources
git clone https://github.com/nbs-system/naxsi.git -q >>"${main_log}" 2>>"${err_log}"
