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

DEBIAN_FRONTEND=noninteractive apt-get -y install build-essential python curl >>"${main_log}" 2>>"${err_log}"

mysql -u root -e "use vmail; grant select, insert, update, delete on vmail.* to 'vmail'@'localhost' identified by '${MAILSERVER_DB_PASS}';"

curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

nvm install 9.1.0
npm i -g pm2

cd /etc/nginx/html/${MYDOMAIN}/
git clone https://github.com/phiilu/mailman.git
cd mailman/
cp sample.env .env

/etc/nginx/html/nxt-server.de/mailman

sed -i "s/^MAILMAN_DB_PASSWORD=vmail/MAILMAN_DB_PASSWORD=${MAILSERVER_DB_PASS}/g" /etc/nginx/html/${MYDOMAIN}/mailman/.env
npm install && cd client && npm install && cd - && npm run build
npm start

}
