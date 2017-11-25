#!/bin/bash
# The perfect rootserver - Your Webserverinstallation Script!
# by shoujii | BoBBer446 > 2017
#####
# https://github.com/shoujii/perfectrootserver
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
# Special thanks to Zypr!
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

install_nginx() {

apt-get -y --assume-yes install libpcre3 libpcre3-dev libgeoip-dev zlib1g-dev >>"${main_log}" 2>>"${err_log}"

cd ~/sources
wget --no-check-certificate http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz >>"${main_log}" 2>>"${err_log}"
tar -xzf nginx-${NGINX_VERSION}.tar.gz >>"${main_log}" 2>>"${err_log}"
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
--with-openssl=$HOME/sources/openssl-${OPENSSL_VERSION} \
--add-module=$HOME/sources/ngx_pagespeed-${NPS_VERSION}-stable"


#--with-openssl-opt=enable-tls1_3 \

if [[ ${USE_AUTOINDEX} == '0' ]]; then
NGINX_MODULES=$(echo $NGINX_MODULES; echo "--without-http_autoindex_module")
fi

if [[ ${USE_BROTLI} == '1' ]]; then
NGINX_MODULES=$(echo $NGINX_MODULES; echo "--add-module=$HOME/sources/ngx_brotli")
fi

./configure $NGINX_OPTIONS $NGINX_MODULES --with-cc-opt='-O2 -g -pipe -Wall -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic' >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to configure nginx! Aborting"

echo "40" | dialog --gauge "Compiling Nginx..." 10 70 0
make -j $(nproc) >>"${main_log}" 2>>"${err_log}"
checkinstall --install=no -y >>"${main_log}" 2>>"${err_log}"

echo "45" | dialog --gauge "Installing Nginx..." 10 70 0
dpkg -i nginx_${NGINX_VERSION}-1_amd64.deb >>"${main_log}" 2>>"${err_log}"
mv nginx_${NGINX_VERSION}-1_amd64.deb ../ >>"${main_log}" 2>>"${err_log}"

mkdir -p /var/lib/nginx/body && cd $_ >>"${main_log}" 2>>"${err_log}"
mkdir ../proxy >>"${main_log}" 2>>"${err_log}"
mkdir ../fastcgi >>"${main_log}" 2>>"${err_log}"
mkdir ../uwsgi >>"${main_log}" 2>>"${err_log}"
mkdir ../cgi >>"${main_log}" 2>>"${err_log}"
mkdir ../nps_cache >>"${main_log}" 2>>"${err_log}"
mkdir -p /var/log/nginx >>"${main_log}" 2>>"${err_log}"
mkdir -p /etc/nginx/sites-available && cd $_ >>"${main_log}" 2>>"${err_log}"
mkdir ../sites-enabled >>"${main_log}" 2>>"${err_log}"
mkdir ../sites-custom >>"${main_log}" 2>>"${err_log}"
mkdir ../htpasswd >>"${main_log}" 2>>"${err_log}"
touch ../htpasswd/.htpasswd >>"${main_log}" 2>>"${err_log}"
mkdir ../logs >>"${main_log}" 2>>"${err_log}"
mkdir ../ssl >>"${main_log}" 2>>"${err_log}"
chown -R www-data:www-data /var/lib/nginx >>"${main_log}" 2>>"${err_log}"
chown www-data:www-data /etc/nginx/logs >>"${main_log}" 2>>"${err_log}"

# Install the Nginx service script
wget -O /etc/init.d/nginx --no-check-certificate https://raw.githubusercontent.com/Fleshgrinder/nginx-sysvinit-script/master/init >>"${main_log}" 2>>"${err_log}"
chmod 0755 /etc/init.d/nginx >>"${main_log}" 2>>"${err_log}"
chown root:root /etc/init.d/nginx >>"${main_log}" 2>>"${err_log}"
update-rc.d nginx defaults >>"${main_log}" 2>>"${err_log}"

rm -rf /etc/nginx/nginx.conf
cat > /etc/nginx/nginx.conf <<END
user www-data;
worker_processes auto;
pid /var/run/nginx.pid;
events {
	worker_connections  4024;
	multi_accept on;
	use epoll;
}
http {
		include       		/etc/nginx/mime.types;
		default_type  		application/octet-stream;
		server_tokens       off;
		keepalive_timeout   70;
		sendfile			on;
		send_timeout 60;
		tcp_nopush on;
		tcp_nodelay on;
		client_max_body_size 50m;
		client_body_timeout 15;
		client_header_timeout 15;
		client_body_buffer_size 1K;
		client_header_buffer_size 1k;
		large_client_header_buffers 4 8k;
		reset_timedout_connection on;
		server_names_hash_bucket_size 100;
		types_hash_max_size 2048;
		open_file_cache max=2000 inactive=20s;
		open_file_cache_valid 60s;
		open_file_cache_min_uses 5;
		open_file_cache_errors off;
		gzip on;
		gzip_static on;
		gzip_disable "msie6";
		gzip_vary on;
		gzip_proxied any;
		gzip_comp_level 6;
		gzip_min_length 1100;
		gzip_buffers 16 8k;
		gzip_http_version 1.1;
		gzip_types text/css text/javascript text/xml text/plain text/x-component application/javascript application/x-javascript application/json application/xml application/rss+xml font/truetype application/x-font-ttf font/opentype application/vnd.ms-fontobject image/svg+xml;
		log_format main     '\$remote_addr - \$remote_user [\$time_local] "\$request" '
							'\$status \$body_bytes_sent "\$http_referer" '
							'"\$http_user_agent" "\$http_x_forwarded_for"';
		access_log		logs/access.log main buffer=16k;
		error_log       	logs/error.log;
		map \$http_referer \$bad_referer {
			default 0;
			~(?i)(adult|babes|click|diamond|forsale|girl|jewelry|love|nudit|organic|poker|porn|poweroversoftware|sex|teen|webcam|zippo|casino|replica) 1;
		}
		map \$http_cookie \$cache_uid {
		  default nil;
		  ~SESS[[:alnum:]]+=(?<session_id>[[:alnum:]]+) \$session_id;
		}

		map \$request_method \$no_cache {
		  default 1;
		  HEAD 0;
		}
		include			/etc/nginx/sites-enabled/*.conf;
}
END

mkdir -p /etc/nginx/html/${MYDOMAIN}

fuser -k 80/tcp >>"${main_log}" 2>>"${err_log}"
systemctl -q restart nginx.service

cp /root/prs-logo.jpg /etc/nginx/html/${MYDOMAIN}/

cat > /etc/nginx/html/${MYDOMAIN}/index.html <<END
<!DOCTYPE html>
<html>
	<head>
		<title>${MYDOMAIN}</title>
	</head>
	<body>
		<center><img src="prs-logo.jpg" alt="prs-logo.jpg" style="width:304px;height:228px;"></center>
		<p style="text-align: center;">
			Herzlich willkommen!</p>
		<p style="text-align: center;">
			Der &gt;<a href="http://perfectrootserver.de" target="_blank">Perfectrootserver</a>&lt; wurde erfolgreich auf deinem Server eingerichtet!</p>
		<p style="text-align: center;">
			Du kannst dich mit den Zugangsdaten aus dem Terminal nun in dein System einloggen.</p>
		<p style="text-align: center;">
			&nbsp;</p>
	</body>
</html>

END

#Make folder writeable
chown -R www-data:www-data /etc/nginx/html/${MYDOMAIN}
}