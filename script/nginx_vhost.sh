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

install_nginx_vhost() {

rm -rf /etc/nginx/sites-available/${MYDOMAIN}.conf
cat > /etc/nginx/sites-available/${MYDOMAIN}.conf <<END
server {
			listen 				80 default_server;
			server_name 		${IPADR} ${MYDOMAIN};
			return 301 			https://${MYDOMAIN}\$request_uri;
}
server {
			listen 				443;
			server_name 		${IPADR} www.${MYDOMAIN} mail.${MYDOMAIN};
			return 301 			https://${MYDOMAIN}\$request_uri;
}
server {
			listen 				443 ssl http2 default deferred;
			server_name 		${MYDOMAIN};
			root 				/etc/nginx/html/${MYDOMAIN};
			index 				index.php index.html index.htm;
			charset 			utf-8;
			error_page 404 		/index.php;
			${SSL_CERT_ECC}
			${SSL_KEY_ECC}
			${SSL_CERT_RSA}
			${SSL_KEY_RSA}
			#ssl_trusted_certificate ssl/${MYDOMAIN}.cer;
			ssl_dhparam	     	ssl/dh.pem;
			#ssl_ecdh_curve 		X25519:secp384r1;
			ssl_session_cache   shared:SSL:10m;
			ssl_session_timeout 10m;
			ssl_session_tickets off;
			ssl_protocols       TLSv1.2 TLSv1.3;
			ssl_prefer_server_ciphers on;
			ssl_buffer_size 	1400;
			#ssl_stapling 		on;
			#ssl_stapling_verify on;
			#resolver 			8.8.8.8 8.8.4.4 208.67.222.222 208.67.220.220 valid=60s;
			#resolver_timeout 	2s;
			ssl_ciphers 		"EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 EECDH+aRSA+SHA256 EECDH EDH+aRSA !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS !RC4";
			#add_header 		Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
			##add_header 		Public-Key-Pins 'pin-sha256="PIN1"; pin-sha256="PIN2"; max-age=5184000; includeSubDomains';
			add_header 			Cache-Control "public";
			add_header 			X-Frame-Options SAMEORIGIN;
			add_header 			Alternate-Protocol  443:npn-http/2;
			add_header 			X-Content-Type-Options nosniff;
			add_header 			X-XSS-Protection "1; mode=block";
			add_header 			X-Permitted-Cross-Domain-Policies "master-only";
			add_header 			"X-UA-Compatible" "IE=Edge";
			add_header 			"Access-Control-Allow-Origin" "*";
			add_header 			Content-Security-Policy "script-src 'self' 'unsafe-inline' 'unsafe-eval' *.youtube.com maps.gstatic.com *.googleapis.com *.google-analytics.com cdnjs.cloudflare.com assets.zendesk.com connect.facebook.net; frame-src 'self' *.youtube.com assets.zendesk.com *.facebook.com s-static.ak.facebook.com tautt.zendesk.com; object-src 'self'";
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
			# This will correctly rewrite your subresources with https:// URLs and thus avoid mixed content warnings.
			# Note, that you should only enable this option if you are behind a load-balancer that will set this header,
			# otherwise your users will be able to set the protocol PageSpeed uses to interpret the request.
			#
			#pagespeed 			RespectXForwardedProto on;
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
				fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
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
			location ~* ^.+\.(css|js)\$ {
				rewrite ^(.+)\.(\d+)\.(css|js)\$ \$1.\$3 last;
				expires 30d;
				access_log off;
				log_not_found off;
				add_header Pragma public;
				add_header Cache-Control "max-age=2592000, public";
			}
			location ~* \.(asf|asx|wax|wmv|wmx|avi|bmp|class|divx|doc|docx|eot|exe|gif|gz|gzip|ico|jpg|jpeg|jpe|mdb|mid|midi|mov|qt|mp3|m4a|mp4|m4v|mpeg|mpg|mpe|mpp|odb|odc|odf|odg|odp|ods|odt|ogg|ogv|otf|pdf|png|pot|pps|ppt|pptx|ra|ram|svg|svgz|swf|tar|t?gz|tif|tiff|ttf|wav|webm|wma|woff|wri|xla|xls|xlsx|xlt|xlw|zip)\$ {
				expires 30d;
				access_log off;
				log_not_found off;
				add_header Pragma public;
				add_header Cache-Control "max-age=2592000, public";
			}
			if (\$http_user_agent ~* "FeedDemon|JikeSpider|Indy Library|Alexa Toolbar|AskTbFXTV|AhrefsBot|CrawlDaddy|CoolpadWebkit|Java|Feedly|UniversalFeedParser|ApacheBench|Microsoft URL Control|Swiftbot|ZmEu|oBot|jaunty|Python-urllib|lightDeckReports Bot|YYSpider|DigExt|YisouSpider|HttpClient|MJ12bot|heritrix|EasouSpider|Ezooms|Scrapy") {
            	return 403;
            }
}
END

if [[ ${USE_PHP7_1} == '1' ]]; then
	sed -i 's/fastcgi_pass unix:\/var\/run\/php\/php7.0-fpm.sock\;/fastcgi_pass unix:\/var\/run\/php\/php7.1-fpm.sock\;/g' /etc/nginx/sites-available/${MYDOMAIN}.conf >>"${main_log}" 2>>"${err_log}"
fi

if [[ ${USE_PHP7_2} == '1' ]]; then
	sed -i 's/fastcgi_pass unix:\/var\/run\/php\/php7.0-fpm.sock\;/fastcgi_pass unix:\/var\/run\/php\/php7.2-fpm.sock\;/g' /etc/nginx/sites-available/${MYDOMAIN}.conf >>"${main_log}" 2>>"${err_log}"
fi

ln -s /etc/nginx/sites-available/${MYDOMAIN}.conf /etc/nginx/sites-enabled/${MYDOMAIN}.conf

if [[ ${CLOUDFLARE} == '0' ]] && [[ ${USE_VALID_SSL} == '1' ]]; then
	sed -i "s/#ssl/ssl/g" /etc/nginx/sites-available/${MYDOMAIN}.conf
	sed -i "s/#resolver/resolver/g" /etc/nginx/sites-available/${MYDOMAIN}.conf
	sed -i "s/#add/add/g" /etc/nginx/sites-available/${MYDOMAIN}.conf
fi
}