#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_openssl() {

mkdir -p ${SCRIPT_PATH}/sources/

apt-get install -y libtool zlib1g-dev libpcre3-dev libssl-dev libxslt1-dev libxml2-dev libgd2-xpm-dev libgeoip-dev libgoogle-perftools-dev libperl-dev >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install openssl packages"

cd ${SCRIPT_PATH}/sources
#wget --no-check-certificate https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz --tries=3 >>"${main_log}" 2>>"${err_log}"
wget https://github.com/openssl/openssl/archive/OpenSSL_${OPENSSL_VERSION}.tar.gz --tries=3 >>${main_log}" 2>>"${err_log}"
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
./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib shared zlib-dynamic -Wl,-R,'$(LIBRPATH)' -Wl,--enable-new-dtags >>"${make_log}" 2>>"${make_err_log}" || error_exit "Failed to configure openssl"

make -j $(nproc) >>"${make_log}" 2>>"${make_err_log}" || error_exit "Failed to make openssl"
make install >>"${make_log}" 2>>"${make_err_log}" || error_exit "Failed to install openssl"

}
