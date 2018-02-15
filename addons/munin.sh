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

install_munin() {

DEBIAN_FRONTEND=noninteractive apt-get -y install munin munin-node munin-plugins-extra apache2-utils >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install munin packages"

MUNIN_HTTPAUTH_PASS=$(password)

htpasswd -b /etc/nginx/htpasswd/.htpasswd ${MUNIN_HTTPAUTH_USER} ${MUNIN_HTTPAUTH_PASS} >>"${main_log}" 2>>"${err_log}"

cat >> /etc/nginx/sites-custom/munin.conf << 'EOF1'
location /munin/static/ {
        alias /etc/munin/static/;
        expires modified +1w;
}

location /munin/ {
        auth_basic            "Restricted";
        # Create the htpasswd file with the htpasswd tool.
        auth_basic_user_file  /etc/nginx/htpasswd;

        alias /var/cache/munin/www/;
        expires modified +310s;
}
location ^~ /munin-cgi/munin-cgi-graph/ {
       access_log off;
       fastcgi_split_path_info ^(/munin-cgi/munin-cgi-graph)(.*);
       fastcgi_param PATH_INFO $fastcgi_path_info;
       fastcgi_pass unix:/var/run/munin/fcgi-graph.sock;
       include fastcgi_params;
}
EOF1

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "Munin Address: ${MYDOMAIN}/munin" >> ${SCRIPT_PATH}/login_information
echo "MUNIN_HTTPAUTH_USER = ${MUNIN_HTTPAUTH_USER}" >> ${SCRIPT_PATH}/login_information
echo "MUNIN_HTTPAUTH_PASS = ${MUNIN_HTTPAUTH_PASS}" >> ${SCRIPT_PATH}/login_information
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information

service nginx restart
}
