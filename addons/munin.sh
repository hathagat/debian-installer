#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_munin() {

set -x

DEBIAN_FRONTEND=noninteractive apt-get -y install munin munin-node munin-plugins-extra apache2-utils >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install munin packages"

MUNIN_HTTPAUTH_PASS=$(password)

htpasswd -b /etc/nginx/htpasswd/.htpasswd ${MUNIN_HTTPAUTH_USER} ${MUNIN_HTTPAUTH_PASS} >>"${main_log}" 2>>"${err_log}"

cat >> /etc/nginx/sites-custom/munin.conf << END
#cat >> /etc/nginx/sites-custom/munin.conf << 'EOF1'
location /munin/static/ {
        alias /etc/munin/static/;
        expires modified +1w;
}
location /munin/ {
        auth_basic            "Restricted";
        alias /var/cache/munin/www/;
        expires modified +310s;
}
location ^~ /munin-cgi/munin-cgi-graph/ {
       access_log off;
       fastcgi_split_path_info ^(/munin-cgi/munin-cgi-graph)(.*);
       fastcgi_param PATH_INFO $fastcgi_path_info;
       #fastcgi_pass unix:/var/run/munin/fcgi-graph.sock;
       fastcgi_pass unix:/var/run/php/php7.1-fpm.sock;i
       nclude fastcgi_params;
}
#EOF1
END

if [[ ${USE_PHP5} == '1' ]]; then
	sed -i 's/fastcgi_pass unix:\/var\/run\/php\/php7.1-fpm.sock\;/fastcgi_pass unix:\/var\/run\/php5-fpm.sock\;/g' /etc/nginx/sites-custom/munin.conf
fi

if [[ ${USE_PHP7_2} == '1' ]]; then
	sed -i 's/fastcgi_pass unix:\/var\/run\/php\/php7.1-fpm.sock\;/fastcgi_pass unix:\/var\/run\/php\/php7.2-fpm.sock\;/g' /etc/nginx/sites-custom/munin.conf
fi

#sed -i "s/INSERT_SERVER_IP/${IPADDR}/g" /etc/nginx/sites-custom/munin.conf
sed -i "s/localhost.localdomain/mail.${MYDOMAIN}/g" /etc/munin/munin.conf

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "Munin Address: ${MYDOMAIN}/munin" >> ${SCRIPT_PATH}/login_information.txt
echo "MUNIN_HTTPAUTH_USER = ${MUNIN_HTTPAUTH_USER}" >> ${SCRIPT_PATH}/login_information.txt
echo "MUNIN_HTTPAUTH_PASS = ${MUNIN_HTTPAUTH_PASS}" >> ${SCRIPT_PATH}/login_information.txt
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information.txt
echo "" >> ${SCRIPT_PATH}/login_information.txt

service munin-node restart
service nginx restart
}
