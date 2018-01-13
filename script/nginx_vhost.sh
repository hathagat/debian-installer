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

install_nginx_vhost() {

rm -rf /etc/nginx/sites-available/${MYDOMAIN}.conf
cat > /etc/nginx/sites-available/${MYDOMAIN}.conf <<END
server {
	server_name ${MYDOMAIN} www.${MYDOMAIN};
	return 301 https://${MYDOMAIN}$request_uri;
}

server {
	listen	443 ssl http2 default deferred;
	server_name ${MYDOMAIN} www.${MYDOMAIN};
	root	/etc/nginx/html/${MYDOMAIN};
	index 				index.php index.html index.htm;
	charset 			utf-8;
	error_page 404 		/index.php;

	ssl_certificate 	ssl/${MYDOMAIN}-ecc.cer;
	ssl_certificate_key ssl/${MYDOMAIN}-ecc.key;
	ssl_trusted_certificate ssl/${MYDOMAIN}-ecc.cer;
	ssl_ciphers	'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA';
	ssl_ecdh_curve	secp521r1:secp384r1;
	ssl_prefer_server_ciphers   on;
	ssl_protocols       TLSv1.2 TLSv1.3;

	ssl_stapling 		on;
	ssl_stapling_verify on;
	resolver 9.9.9.9 8.8.8.8 8.8.4.4 valid=3m;
	resolver_timeout 	2s;
	ssl_buffer_size 	1400;
	ssl_session_cache   shared:SSL:10m;
	ssl_session_timeout 10m;
	ssl_session_tickets off;

	add_header 		Alternate-Protocol  443:npn-http/2;
	add_header 		Strict-Transport-Security "max-age=63072000; includeSubdomains; preload" always;
	add_header 		Public-Key-Pins 'pin-sha256="${HPKP1}"; pin-sha256="${HPKP2}"; max-age=5184000; includeSubDomains';
	add_header 		X-Frame-Options SAMEORIGIN;
	add_header 		X-Xss-Protection "1; mode=block" always;
	add_header 		X-Content-Type-Options "nosniff" always;
	add_header 		Cache-Control "public";
	add_header 		X-Permitted-Cross-Domain-Policies "master-only";
	add_header 		"X-UA-Compatible" "IE=Edge";
	add_header 		"Access-Control-Allow-Origin" "*";
	add_header 		'Referrer-Policy' 'strict-origin';
	add_header 		Content-Security-Policy "script-src 'self' *.youtube.com maps.gstatic.com *.googleapis.com *.google-analytics.com cdnjs.cloudflare.com assets.zendesk.com connect.facebook.net; frame-src 'self' *.youtube.com assets.zendesk.com *.facebook.com s-static.ak.facebook.com tautt.zendesk.com; object-src 'self'";

	brotli on;
			brotli_static on;
			brotli_buffers 16 8k;
			brotli_comp_level 6;
			brotli_types
					text/css
					text/javascript
					text/xml
					text/plain
					text/x-component
					application/javascript
					application/x-javascript
					application/json
					application/xml
					application/rss+xml
					application/atom+xml
					application/rdf+xml
					application/vnd.ms-fontobject
					font/truetype
					font/opentype
					image/svg+xml;

	pagespeed 			on;
	pagespeed 			EnableFilters collapse_whitespace;
	pagespeed 			EnableFilters canonicalize_javascript_libraries;
	pagespeed 			EnableFilters combine_css;
	pagespeed 			EnableFilters combine_javascript;
	pagespeed 			EnableFilters elide_attributes;
	pagespeed 			EnableFilters extend_cache;
	pagespeed 			EnableFilters flatten_css_imports;
	pagespeed 			EnableFilters lazyload_images;
	pagespeed 			EnableFilters rewrite_javascript;
	pagespeed 			EnableFilters rewrite_images;
	pagespeed 			EnableFilters insert_dns_prefetch;
	pagespeed 			EnableFilters prioritize_critical_css;
	pagespeed 			FetchHttps enable,allow_self_signed;
	pagespeed 			FileCachePath /var/lib/nginx/nps_cache;
	pagespeed 			RewriteLevel CoreFilters;
	pagespeed 			CssFlattenMaxBytes 5120;
	pagespeed 			LogDir /var/log/pagespeed;
	pagespeed 			EnableCachePurge on;
	pagespeed 			PurgeMethod PURGE;
	pagespeed 			DownstreamCachePurgeMethod PURGE;
	pagespeed 			DownstreamCachePurgeLocationPrefix http://127.0.0.1:80/;
	pagespeed 			DownstreamCacheRewrittenPercentageThreshold 95;
	pagespeed 			LazyloadImagesAfterOnload on;
	pagespeed 			LazyloadImagesBlankUrl "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7";
	pagespeed 			MemcachedThreads 1;
	pagespeed 			MemcachedServers "localhost:11211";
	pagespeed 			MemcachedTimeoutUs 100000;
	pagespeed 			RespectVary on;
	pagespeed 			Disallow "*/pma/*";

	auth_basic_user_file htpasswd/.htpasswd;
	location ~ \.php\$ {
		fastcgi_split_path_info ^(.+\.php)(/.+)\$;
		if (!-e \$document_root\$fastcgi_script_name) {
			return 404;
		}
		try_files \$fastcgi_script_name =404;
		fastcgi_param PATH_INFO \$fastcgi_path_info;
		fastcgi_param PATH_TRANSLATED \$document_root\$fastcgi_path_info;
		fastcgi_param APP_ENV production;
		fastcgi_pass unix:/var/run/php/php7.1-fpm.sock;
		fastcgi_index index.php;
		include fastcgi.conf;
		fastcgi_intercept_errors off;
		fastcgi_ignore_client_abort off;
		fastcgi_buffers 256 16k;
		fastcgi_buffer_size 128k;
		fastcgi_connect_timeout 3s;
		fastcgi_send_timeout 120s;
		fastcgi_read_timeout 120s;
		fastcgi_busy_buffers_size 256k;
		fastcgi_temp_file_write_size 256k;
	}
	include /etc/nginx/sites-custom/*.conf;
	location / {
		# Uncomment, if you need to remove index.php from the
		# URL. Usefull if you use Codeigniter, Zendframework, etc.
		# or just need to remove the index.php
		#
		#try_files \$uri \$uri/ /index.php?\$args;
	}
	location ~* /\.(?!well-known\/) {
		deny all;
		access_log off;
		log_not_found off;
	}
	location ~* (?:\.(?:bak|conf|dist|fla|in[ci]|log|psd|sh|sql|sw[op])|~)$ {
		deny all;
		access_log off;
		log_not_found off;
	}
	location = /favicon.ico {
		access_log off;
		log_not_found off;
	}
	location = /robots.txt {
		allow all;
		access_log off;
		log_not_found off;
	}
	if (\$http_user_agent ~* "FeedDemon|JikeSpider|Indy Library|Alexa Toolbar|AskTbFXTV|AhrefsBot|CrawlDaddy|CoolpadWebkit|Java|Feedly|UniversalFeedParser|ApacheBench|Microsoft URL Control|Swiftbot|ZmEu|oBot|jaunty|Python-urllib|lightDeckReports Bot|YYSpider|DigExt|YisouSpider|HttpClient|MJ12bot|heritrix|EasouSpider|Ezooms|Scrapy") {
		return 403;
	}
}

END

if [[ ${USE_PHP7_2} == '1' ]]; then
	sed -i 's/fastcgi_pass unix:\/var\/run\/php\/php7.1-fpm.sock\;/fastcgi_pass unix:\/var\/run\/php\/php7.2-fpm.sock\;/g' /etc/nginx/sites-available/${MYDOMAIN}.conf >>"${main_log}" 2>>"${err_log}"
fi

ln -s /etc/nginx/sites-available/${MYDOMAIN}.conf /etc/nginx/sites-enabled/${MYDOMAIN}.conf
}
