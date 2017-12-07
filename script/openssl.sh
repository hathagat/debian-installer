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

menu_options_openssl() {

HEIGHT=30
WIDTH=60
CHOICE_HEIGHT=4
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

	OPTIONS=(1 "Install Openssl"
			 2 "Update Openssl"
			 3 "Back"
			 4 "Exit")

	CHOICE=$(dialog --clear \
					--nocancel \
					--no-cancel \
					--backtitle "$BACKTITLE" \
					--title "$TITLE" \
					--menu "$MENU" \
					$HEIGHT $WIDTH $CHOICE_HEIGHT \
					"${OPTIONS[@]}" \
					2>&1 >/dev/tty)

	clear
	case $CHOICE in
			1)
				dialog --backtitle "NeXt Server Installation" --infobox "Installing Openssl" $HEIGHT $WIDTH
				source /root/script/logs.sh; set_logs
				source /root/script/prerequisites.sh; prerequisites
				install_openssl
				dialog --backtitle "NeXt Server Installation" --msgbox "Finished installing Openssh" $HEIGHT $WIDTH
				exit 1
				;;
			2)
			    dialog --backtitle "NeXt Server Installation" --infobox "Updating Openssl" $HEIGHT $WIDTH
				source /root/script/logs.sh; set_logs
				source /root/script/prerequisites.sh; prerequisites
				update_openssl
				dialog --backtitle "NeXt Server Installation" --msgbox "Finished updating Openssl" $HEIGHT $WIDTH
				;;
			3)
				bash /root/start.sh;
				;;
			4)
				echo "Exit"
				exit 1
				;;
	esac
}

install_openssl() {

mkdir -p ~/sources/

apt-get install -y libtool zlib1g-dev libpcre3-dev libssl-dev libxslt1-dev libxml2-dev libgd2-xpm-dev libgeoip-dev libgoogle-perftools-dev libperl-dev >>"${main_log}" 2>>"${err_log}"

cd ~/sources
wget --no-check-certificate https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz --tries=3 >>"${main_log}" 2>>"${err_log}"
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: openssl-${OPENSSL_VERSION}.tar.gz download failed."
      exit
    fi

tar -xzf openssl-${OPENSSL_VERSION}.tar.gz >>"${main_log}" 2>>"${err_log}"
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: openssl-${OPENSSL_VERSION}.tar.gz is corrupted."
      exit
    fi
rm openssl-${OPENSSL_VERSION}.tar.gz

cd openssl-${OPENSSL_VERSION}

./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib shared zlib-dynamic >>"${make_log}" 2>>"${make_err_log}"

make -j $(nproc) >>"${make_log}" 2>>"${make_err_log}"
make install >>"${make_log}" 2>>"${make_err_log}"

}

update_openssl() {

source configs/versions.cfg

LOCAL_OPENSSL_VERSION_STRING=$(openssl version)
LOCAL_OPENSSL_VERSION=$(echo $LOCAL_OPENSSL_VERSION_STRING | cut -c9-14)

if [[ ${LOCAL_OPENSSL_VERSION} != ${OPENSSL_VERSION} ]]; then

	apt-get install -y libtool zlib1g-dev libpcre3-dev libssl-dev libxslt1-dev libxml2-dev libgd2-xpm-dev libgeoip-dev libgoogle-perftools-dev libperl-dev >>"${main_log}" 2>>"${err_log}"

	mkdir -p ~/sources/

	cd ~/sources
	wget --no-check-certificate https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz --tries=3 >>"${main_log}" 2>>"${err_log}"
		ERROR=$?
		if [[ "$ERROR" != '0' ]]; then
		  echo "Error: openssl-${OPENSSL_VERSION}.tar.gz download failed."
		  exit
		fi

	tar -xzf openssl-${OPENSSL_VERSION}.tar.gz >>"${main_log}" 2>>"${err_log}"
		ERROR=$?
		if [[ "$ERROR" != '0' ]]; then
		  echo "Error: openssl-${OPENSSL_VERSION}.tar.gz is corrupted."
		  exit
		fi
	rm openssl-${OPENSSL_VERSION}.tar.gz

	cd openssl-${OPENSSL_VERSION}

	./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib shared zlib-dynamic >>"${make_log}" 2>>"${make_err_log}"

	make -j $(nproc) >>"${make_log}" 2>>"${make_err_log}"
	make install >>"${make_log}" 2>>"${make_err_log}"

else

	HEIGHT=10
	WIDTH=70
	dialog --backtitle "NeXt Server installation!" --infobox "No Openssl Update needed! Local Openssl Version: ${LOCAL_OPENSSL_VERSION}. Version to be installed: ${OPENSSL_VERSION}" $HEIGHT $WIDTH
	exit 1
fi
}
