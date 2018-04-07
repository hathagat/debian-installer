#!/bin/bash

install_nginx_addons() {

install_packages "autoconf automake libtool git unzip zlib1g-dev libpcre3 libpcre3-dev uuid-dev"

cd ${SCRIPT_PATH}/sources
wget_tar "https://codeload.github.com/pagespeed/ngx_pagespeed/zip/v${NPS_VERSION}"
unzip_file "v${NPS_VERSION}"
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
unzip_file "v${NGINX_HEADER_MOD_VERSION}"

cd ${SCRIPT_PATH}/sources
git clone https://github.com/nbs-system/naxsi.git -q >>"${main_log}" 2>>"${err_log}"
}
