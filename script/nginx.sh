#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_nginx() {

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

./configure $NGINX_OPTIONS $NGINX_MODULES --with-cc-opt='-O2 -g -pipe -Wall -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong -m64 -mtune=generic' >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to configure nginx"

make -j $(nproc) >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to make nginx"
checkinstall --install=no -y >>"${main_log}" 2>>"${err_log}"

dpkg -i nginx_${NGINX_VERSION}-1_amd64.deb >>"${main_log}" 2>>"${err_log}"
mv nginx_${NGINX_VERSION}-1_amd64.deb ../ >>"${main_log}" 2>>"${err_log}"

rm -R ${SCRIPT_PATH}/sources/nginx-${NGINX_VERSION}
rm -R ${SCRIPT_PATH}/sources/libbrotli
rm -R ${SCRIPT_PATH}/sources/ngx_brotli

mkdir -p /etc/nginx
mkdir -p /etc/nginx/sites
mkdir -p /etc/nginx/ssl
mkdir -p /var/cache/nginx
mkdir -p /var/log/nginx/
mkdir -p /etc/nginx/sites-available/
mkdir -p /etc/nginx/sites-enabled/
mkdir -p /etc/nginx/sites-custom/
mkdir -p /etc/nginx/htpasswd/
touch /etc/nginx/htpasswd/.htpasswd

# Install the Nginx service script
wget -O /etc/init.d/nginx -c4 --no-check-certificate https://raw.githubusercontent.com/Fleshgrinder/nginx-sysvinit-script/master/init --tries=3 >>"${main_log}" 2>>"${err_log}"
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: nginx-sysvinit-script download failed."
      exit
    fi

chmod 0755 /etc/init.d/nginx >>"${main_log}" 2>>"${err_log}"
chown root:root /etc/init.d/nginx >>"${main_log}" 2>>"${err_log}"
update-rc.d nginx defaults >>"${main_log}" 2>>"${err_log}"

rm -rf /etc/nginx/nginx.conf
cp ${SCRIPT_PATH}/configs/nginx/nginx.conf /etc/nginx/nginx.conf

mkdir -p /etc/nginx/html/${MYDOMAIN}
systemctl -q restart nginx.service

cp ${SCRIPT_PATH}/includes/NeXt-logo.jpg /etc/nginx/html/${MYDOMAIN}/
cp ${SCRIPT_PATH}/configs/nginx/index.html /etc/nginx/html/${MYDOMAIN}/index.html

#Make folder writeable
chown -R www-data:www-data /etc/nginx/html/${MYDOMAIN}
#chmod og+x /etc/nginx/html/${MYDOMAIN}


#########################
#sed -i "s/MYDOMAIN/${MYDOMAIN}/g" /etc/nginx/sites-available/${MYDOMAIN}.conf
#if [[ ${USE_PHP7_2} == '1' ]]; then
#	sed -i 's/fastcgi_pass unix:\/var\/run\/php\/php7.1-fpm.sock\;/fastcgi_pass unix:\/var\/run\/php\/php7.2-fpm.sock\;/g' /etc/nginx/sites-available/${MYDOMAIN}.conf >>"${main_log}" 2>>"${err_log}"
#fi

#ln -s /etc/nginx/sites-available/${MYDOMAIN}.conf /etc/nginx/sites-enabled/${MYDOMAIN}.conf

}
