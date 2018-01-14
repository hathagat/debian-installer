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

install_rainloop() {

mkdir -p /etc/nginx/html/${MYDOMAIN}/webmail
cd /etc/nginx/html/${MYDOMAIN}/
wget --no-check-certificate https://www.rainloop.net/repository/webmail/rainloop-latest.zip --tries=3 >>"${main_log}" 2>>"${err_log}"
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: rainloop-latest.zip download failed."
      exit
    fi

unzip rainloop-latest.zip -d /etc/nginx/html/${MYDOMAIN}/webmail >>"${main_log}" 2>>"${err_log}"
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: rainloop-latest.zip is corrupted."
      exit
    fi
rm rainloop-latest.zip

cd /etc/nginx/html/${MYDOMAIN}/webmail
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
chown -R www-data:www-data .

#RAINLOOP_ADMIN_PASSWORT=$(password)
#sed -i "s/12345/${RAINLOOP_ADMIN_PASSWORT}/g" /etc/nginx/html/${MYDOMAIN}/webmail/data/_data_/_default_/configs/application.ini

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "Rainloop Admin URL:" >> ${SCRIPT_PATH}/login_information
echo "https://${MYDOMAIN}/webmail/?admin" >> ${SCRIPT_PATH}/login_information
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "Rainloop Admin Login:" >> ${SCRIPT_PATH}/login_information
echo "User: admin" >> ${SCRIPT_PATH}/login_information
echo "Password please change immediately: 12345" >> ${SCRIPT_PATH}/login_information
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "Rainloop Webmail URL:" >> ${SCRIPT_PATH}/login_information
echo "https://${MYDOMAIN}/webmail/ >> ${SCRIPT_PATH}/login_information
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information

}
