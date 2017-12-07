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

update_script() {

mkdir -p /root/backup_next_server

#backup first

### add more important stuff to backup ###
mkdir -p /root/backup_next_server/logs
cp ${SCRIPT_PATH}/logs/* /root/backup_next_server/logs/
cp ${SCRIPT_PATH}/login_information /root/backup_next_server/
cp ${SCRIPT_PATH}/ssh_privatekey.txt /root/backup_next_server/

#reset branch
cd ${SCRIPT_PATH}
git reset --hard origin/master

#restore backup


}
