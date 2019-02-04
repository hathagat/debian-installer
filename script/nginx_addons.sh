#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_nginx_addons() {

trap error_exit ERR

install_packages "autoconf automake libtool git unzip zlib1g-dev libpcre3 libpcre3-dev uuid-dev"

cd ${SCRIPT_PATH}/sources
wget_tar "https://codeload.github.com/pagespeed/ngx_pagespeed/zip/v${NPS_VERSION}"
unzip_file "v${NPS_VERSION}"
cd incubator-pagespeed-ngx-${NPS_VERSION}/ >>"${main_log}" 2>>"${err_log}"

wget_tar "https://dl.google.com/dl/page-speed/psol/${PSOL_VERSION}-x64.tar.gz"
tar_file "${PSOL_VERSION}-x64.tar.gz"

cd ${SCRIPT_PATH}/sources
wget_tar "https://codeload.github.com/openresty/headers-more-nginx-module/zip/v${NGINX_HEADER_MOD_VERSION}"
unzip_file "v${NGINX_HEADER_MOD_VERSION}"

cd ${SCRIPT_PATH}/sources
git clone https://github.com/nbs-system/naxsi.git -q >>"${main_log}" 2>>"${err_log}"
}
