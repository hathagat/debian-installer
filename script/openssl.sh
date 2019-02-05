#!/bin/bash
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_openssl() {

trap error_exit ERR

mkdir -p ${SCRIPT_PATH}/sources/

install_packages "libssl-dev libtool zlib1g-dev libpcre3-dev libxslt1-dev libxml2-dev libgd-dev libgeoip-dev libgoogle-perftools-dev libperl-dev"

cd ${SCRIPT_PATH}/sources
wget_tar "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
tar_file "openssl-${OPENSSL_VERSION}.tar.gz"
cd openssl-${OPENSSL_VERSION}
./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib shared zlib-dynamic -Wl,-R,'$(LIBRPATH)' -Wl,--enable-new-dtags >>"${make_log}" 2>>"${make_err_log}"
make -j $(nproc) >>"${make_log}" 2>>"${make_err_log}"
make install >>"${make_log}" 2>>"${make_err_log}"
}
