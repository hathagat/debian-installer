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


install_mailman() {

mysql -u root -p${MYSQL_ROOT_PASS} -e "use vmail; insert into domains (domain) values ('${MYDOMAIN}');"
EMAIL_ACCOUNT_PASS=$(password)

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "Your Email User Name: postmaster@${MYDOMAIN}" >> ${SCRIPT_PATH}/login_information
echo "This is also the Mailman Login" >> ${SCRIPT_PATH}/login_information
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo ""

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "EMAIL_ACCOUNT_PASS: $EMAIL_ACCOUNT_PASS" >> ${SCRIPT_PATH}/login_information
echo "This is also the Mailman Login" >> ${SCRIPT_PATH}/login_information
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo ""

EMAIL_ACCOUNT_PASS_HASH=$(doveadm pw -p ${EMAIL_ACCOUNT_PASS} -s SHA512-CRYPT)
mysql -u root -p${MYSQL_ROOT_PASS} -e "use vmail; insert into accounts (username, domain, password, quota, enabled, sendonly) values ('postmaster', '${MYDOMAIN}', '${EMAIL_ACCOUNT_PASS_HASH}', 2048, true, false);"

DEBIAN_FRONTEND=noninteractive apt-get -y install build-essential python curl >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install build-essential python curl packages"

mysql -u root -p${MYSQL_ROOT_PASS} -e "use vmail; grant select, insert, update, delete on vmail.* to 'vmail'@'localhost' identified by '${MAILSERVER_DB_PASS}';"

curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | bash >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to curl nvm"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

nvm install 9.1.0 >>"${main_log}" 2>>"${err_log}"
npm i -g pm2 >>"${main_log}" 2>>"${err_log}"

cd /etc/
git clone https://github.com/phiilu/mailman.git || error_exit "Failed to clone mailman"
cd mailman/
cp sample.env .env

sed -i '/^[[:blank:]]*"homepage"/s#:4000/#:4000/mailman#' /etc/mailman/client/package.json
sed -i "s/^REACT_APP_BASENAME=\//REACT_APP_BASENAME=\/mailman/g" /etc/mailman/client/.env.production

sed -i "s/^MAILMAN_DB_PASSWORD=vmail/MAILMAN_DB_PASSWORD=${MAILSERVER_DB_PASS}/g" /etc/mailman/.env
sed -i "s/^MAILMAN_BASENAME=\//MAILMAN_BASENAME=\/mailman/g" /etc/mailman/.env
sed -i "s/^MAILMAN_ADMIN=florian@example.org/MAILMAN_ADMIN=postmaster@${MYDOMAIN}/g" /etc/mailman/.env

npm install && cd client && npm install && cd - && npm run build >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to build mailman"

pm2 kill

npm start

cat >> /etc/nginx/sites-custom/mailman.conf << 'EOF1'
location /mailman {
  proxy_pass       http://localhost:4000;
  proxy_set_header Host      $host;
  proxy_set_header X-Real-IP $remote_addr;
}
EOF1

echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "Mailman Address: ${MYDOMAIN}/mailman" >> ${SCRIPT_PATH}/login_information
echo "#------------------------------------------------------------------------------#" >> ${SCRIPT_PATH}/login_information
echo "" >> ${SCRIPT_PATH}/login_information

}
