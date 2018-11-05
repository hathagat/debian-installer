#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_openssl() {

mkdir -p ${SCRIPT_PATH}/sources/

#libssl-dev
#temporary fix until 1.1.1 is available in repos
wget_tar "http://ftp.de.debian.org/debian/pool/main/o/openssl/libssl1.1_1.1.1-1_amd64.deb"
dpkg -i libssl1.1_1.1.1-1_amd64.deb >>"${main_log}" 2>>"${err_log}"

install_packages "libtool zlib1g-dev libpcre3-dev libxslt1-dev libxml2-dev libgd-dev libgeoip-dev libgoogle-perftools-dev libperl-dev"

cd ${SCRIPT_PATH}/sources
wget_tar "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
tar_file "openssl-${OPENSSL_VERSION}.tar.gz"
cd openssl-${OPENSSL_VERSION}
./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib shared zlib-dynamic -Wl,-R,'$(LIBRPATH)' -Wl,--enable-new-dtags >>"${make_log}" 2>>"${make_err_log}" || error_exit "Failed to configure openssl"

make -j $(nproc) >>"${make_log}" 2>>"${make_err_log}" || error_exit "Failed to make openssl"
make install >>"${make_log}" 2>>"${make_err_log}" || error_exit "Failed to install openssl"

}
