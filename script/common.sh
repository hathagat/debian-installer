#!/bin/bash
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

install_common() {

# Tools
apt-get -y install curl htop vim >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install common packages"

git clone --depth=1 git://github.com/amix/vimrc.git ~/.vim_runtime >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to clone vimrx"
bash ~/.vim_runtime/install_basic_vimrc.sh >>"${main_log}" 2>>"${err_log}"

# DNS
## CCC       - dns.as250.net
## OpenNIC   - ns3.cz.dns.opennic.glue
## DNS.WATCH - resolver2.dns.watch
cat > /etc/resolv.conf <<END
domain ${MYDOMAIN}
search ${MYDOMAIN}
options rotate
options timeout:1
nameserver 194.150.168.168
nameserver 81.2.241.148
nameserver 84.200.70.40
END

# Bash
git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to clone bash-it"
~/.bash_it/install.sh --silent >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install bash-it"

. ~/.bashrc
bash-it enable plugin docker extract gh git >>"${main_log}" 2>>"${err_log}"
bash-it enable completion defaults docker docker-compose export gh git git_flow_avh makefile ssh >>"${main_log}" 2>>"${err_log}"
sed -i "s/bobby/pure/g" ~/.bashrc
. ~/.bashrc

cat > ~/.bash_profile <<END
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
END

}