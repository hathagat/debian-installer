#!/bin/bash
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

update_nginx() {

trap error_exit ERR

source ${SCRIPT_PATH}/configs/versions.cfg

command="nginx -v"
nginxv=$( ${command} 2>&1 )
LOCAL_NGINX_VERSION=$(echo $nginxv | grep -o '[0-9.]*$')

if [[ ${LOCAL_NGINX_VERSION} != ${NGINX_VERSION} ]]; then
  systemctl -q stop nginx.service

  ###cp folders with vhost, html folder etc -> user permissions changed? sop service + download updated addons before compile

  #do not delete /backup/ folder
  mkdir /root/backup/$date/nginx/
  cp -R /etc/nginx/* /root/backup/$date/nginx/

  #download openssl again or use old folder? what if user deleted it? <-- but in all update openssl folder will be created?
  cd /root/update/sources/
  wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz >>"$main_log" 2>>"$err_log"
  tar -xzf openssl-${OPENSSL_VERSION}.tar.gz >>"$main_log" 2>>"$err_log"

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


  ##nginx
  install_packages "psmisc libpcre3 libpcre3-dev libgeoip-dev zlib1g-dev checkinstall"

  cd ${SCRIPT_PATH}/sources
  wget_tar "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz"
  tar_file "nginx-${NGINX_VERSION}.tar.gz"
  cd nginx-${NGINX_VERSION} >>"${main_log}" 2>>"${err_log}"

  #Thanks to https://github.com/Angristan/nginx-autoinstall/
  NGINX_OPTIONS="
  --prefix=/etc/nginx \
  --sbin-path=/usr/sbin/nginx \
  --conf-path=/etc/nginx/nginx.conf \
  --error-log-path=/var/log/nginx/error.log \
  --http-log-path=/var/log/nginx/access.log \
  --pid-path=/var/run/nginx.pid \
  --lock-path=/var/run/nginx.lock \
  --http-client-body-temp-path=/var/lib/nginx/body \
  --http-proxy-temp-path=/var/lib/nginx/proxy \
  --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
  --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
  --http-scgi-temp-path=/var/lib/nginx/scgi \
  --user=www-data \
  --group=www-data"

  NGINX_MODULES="--without-http_browser_module \
  --without-http_empty_gif_module \
  --without-http_userid_module \
  --without-http_split_clients_module \
  --with-http_ssl_module \
  --with-http_gzip_static_module \
  --with-http_stub_status_module \
  --with-http_sub_module \
  --with-http_addition_module \
  --with-http_realip_module \
  --with-http_geoip_module \
  --with-threads \
  --with-stream \
  --with-stream_ssl_module \
  --with-pcre \
  --with-pcre-jit \
  --with-mail \
  --with-mail_ssl_module \
  --with-http_v2_module \
  --with-http_random_index_module \
  --with-http_auth_request_module \
  --with-http_secure_link_module \
  --with-http_flv_module \
  --with-http_dav_module \
  --with-http_mp4_module \
  --with-http_gunzip_module \
  --with-openssl-opt=enable-tls1_3 \
  --with-openssl=${SCRIPT_PATH}/sources/openssl-${OPENSSL_VERSION} \
  --add-module=${SCRIPT_PATH}/sources/naxsi/naxsi_src \
  --add-module=${SCRIPT_PATH}/sources/incubator-pagespeed-ngx-${NPS_VERSION} \
  --add-module=${SCRIPT_PATH}/sources/headers-more-nginx-module-${NGINX_HEADER_MOD_VERSION} \
  --add-module=${SCRIPT_PATH}/sources/ngx_brotli "

  ./configure $NGINX_OPTIONS $NGINX_MODULES --with-cc-opt='-O2 -g -pipe -Wall -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong -m64 -mtune=generic' >>"${main_log}" 2>>"${err_log}"

  make -j $(nproc) >>"${main_log}" 2>>"${err_log}"
  checkinstall --install=no -y >>"${main_log}" 2>>"${err_log}"

  dpkg -i nginx_${NGINX_VERSION}-1_amd64.deb >>"${main_log}" 2>>"${err_log}"
  mv nginx_${NGINX_VERSION}-1_amd64.deb ../ >>"${main_log}" 2>>"${err_log}"

  ###cp back folders with vhost, html folder etc -> user permissions changed? start service
  ##autostart script working?
  cp -R /root/backup/$date/nginx/* /etc/nginx/
  systemctl -q start nginx.service
fi
}
