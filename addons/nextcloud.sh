#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_nextcloud() {

DEBIAN_FRONTEND=noninteractive apt-get -y install unzip >>"${main_log}" 2>>"${err_log}"

MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" /root/NeXt-Server/login_information)
echo "${MYSQL_ROOT_PASS}"
NEXTCLOUD_DB_PASS=$(password)

mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE DATABASE nextclouddb;"
mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY '${NEXTCLOUD_DB_PASS}';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "GRANT ALL PRIVILEGES ON nextclouddb.* TO 'nextcloud'@'localhost';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "FLUSH PRIVILEGES;"

cd /srv/
wget https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.zip >>"${main_log}" 2>>"${err_log}"
unzip nextcloud-${NEXTCLOUD_VERSION}.zip
rm nextcloud-${NEXTCLOUD_VERSION}.zip

chown -R www-data: /srv/nextcloud
ln -s /srv/nextcloud/ /etc/nginx/html/${MYDOMAIN}/nextcloud >>"${main_log}" 2>>"${err_log}"

cat >> /etc/nginx/sites-custom/nextcloud.conf << 'EOF1'
# The following 2 rules are only needed for the user_webfinger app.
# Uncomment it if you're planning to use this app.
# rewrite ^/.well-known/host-meta /nextcloud/public.php?service=host-meta
# last;
#rewrite ^/.well-known/host-meta.json
# /nextcloud/public.php?service=host-meta-json last;

location = /.well-known/carddav {
  return 301 $scheme://$host/nextcloud/remote.php/dav;
}
location = /.well-known/caldav {
  return 301 $scheme://$host/nextcloud/remote.php/dav;
}

location /.well-known/acme-challenge { }

location ^~ /nextcloud {

	# set max upload size
	client_max_body_size 512M;
	fastcgi_buffers 64 4K;

	# Enable gzip but do not remove ETag headers
	gzip on;
	gzip_vary on;
	gzip_comp_level 4;
	gzip_min_length 256;
	gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;
	gzip_types application/atom+xml application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;

	# Uncomment if your server is build with the ngx_pagespeed module
	# This module is currently not supported.
	pagespeed off;

	location /nextcloud {
		rewrite ^ /nextcloud/index.php$uri;
	}

	location ~ ^/nextcloud/(?:build|tests|config|lib|3rdparty|templates|data)/ {
		deny all;
	}
	location ~ ^/nextcloud/(?:\.|autotest|occ|issue|indie|db_|console) {
		deny all;
	}

	location ~ ^/nextcloud/(?:index|remote|public|cron|core/ajax/update|status|ocs/v[12]|updater/.+|ocs-provider/.+)\.php(?:$|/) {
		fastcgi_split_path_info ^(.+\.php)(/.*)$;
		include fastcgi_params;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		fastcgi_param PATH_INFO $fastcgi_path_info;
		fastcgi_param HTTPS on;
		#Avoid sending the security headers twice
		fastcgi_param modHeadersAvailable true;
		fastcgi_param front_controller_active true;
		fastcgi_pass unix:/var/run/php/php7.1-fpm.sock;
		fastcgi_intercept_errors on;
		fastcgi_request_buffering off;
	}

	location ~ ^/nextcloud/(?:updater|ocs-provider)(?:$|/) {
		try_files $uri/ =404;
		index index.php;
	}

	# Adding the cache control header for js and css files
	# Make sure it is BELOW the PHP block
	location ~ \.(?:css|js|woff|svg|gif)$ {
		try_files $uri /nextcloud/index.php$uri$is_args$args;
		add_header Cache-Control "public, max-age=15778463";
		# Add headers to serve security related headers  (It is intended
		# to have those duplicated to the ones above)
		# Before enabling Strict-Transport-Security headers please read
		# into this topic first.
		# add_header Strict-Transport-Security "max-age=15768000;
		# includeSubDomains; preload;";
		add_header X-Content-Type-Options nosniff;
		add_header X-XSS-Protection "1; mode=block";
		add_header X-Robots-Tag none;
		add_header X-Download-Options noopen;
		add_header X-Permitted-Cross-Domain-Policies none;
		# Optional: Don't log access to assets
		access_log off;
	}

	location ~ \.(?:png|html|ttf|ico|jpg|jpeg)$ {
		try_files $uri /nextcloud/index.php$uri$is_args$args;
		# Optional: Don't log access to other assets
		access_log off;
	}
}
EOF1

if [[ ${USE_PHP5} == '1' ]]; then
	sed -i 's/fastcgi_pass unix:\/var\/run\/php\/php7.1-fpm.sock\;/fastcgi_pass unix:\/var\/run\/php5-fpm.sock\;/g' /etc/nginx/sites-custom/phpmyadmin.conf
fi

if [[ ${USE_PHP7_2} == '1' ]]; then
	sed -i 's/fastcgi_pass unix:\/var\/run\/php\/php7.1-fpm.sock\;/fastcgi_pass unix:\/var\/run\/php\/php7.2-fpm.sock\;/g' /etc/nginx/sites-custom/nextcloud.conf >>"${main_log}" 2>>"${err_log}"
fi

#ln -s /etc/nginx/sites-available/cloud.${MYDOMAIN}.conf /etc/nginx/sites-enabled/cloud.${MYDOMAIN}.conf

systemctl -q reload nginx.service

echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information
echo "Nextcloud" >> ${SCRIPT_PATH}/login_information
echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information
echo "https://${MYDOMAIN}/nextcloud" >> ${SCRIPT_PATH}/login_information
echo "Database name = nextclouddb" >> ${SCRIPT_PATH}/login_information
echo "Database User: nextcloud" >> ${SCRIPT_PATH}/login_information
echo "Database password = ${NEXTCLOUD_DB_PASS}" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information

echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information_nextcloud
echo "Nextcloud" >> ${SCRIPT_PATH}/login_information_nextcloud
echo "--------------------------------------------" >> ${SCRIPT_PATH}/login_information_nextcloud
echo "https://${MYDOMAIN}/nextcloud" >> ${SCRIPT_PATH}/login_information_nextcloud
echo "Database name = nextclouddb" >> ${SCRIPT_PATH}/login_information_nextcloud
echo "Database User: nextcloud" >> ${SCRIPT_PATH}/login_information_nextcloud
echo "Database password = ${NEXTCLOUD_DB_PASS}" >> ${SCRIPT_PATH}/login_information_nextcloud
echo "" >> ${SCRIPT_PATH}/login_information_nextcloud


dialog --title "Your Nextcloud logininformations" --tab-correct --exit-label "ok" --textbox ${SCRIPT_PATH}/login_information_nextcloud 50 200
}

deinstall_nextcloud() {

rm -r /srv/nextcloud/
rm /etc/nginx/html/${MYDOMAIN}/nextcloud
rm /etc/nginx/sites-custom/nextcloud.conf

service nginx restart

}
