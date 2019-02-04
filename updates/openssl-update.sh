#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

update_openssl() {

trap error_exit ERR	

source ${SCRIPT_PATH}/configs/versions.cfg

#-4 only working for beta releases -> stable releases -3!
LOCAL_OPENSSL_VERSION_STRING=$(openssl version | awk '/OpenSSL/ {print $(NF-4)}')

if [[ ${LOCAL_OPENSSL_VERSION} != ${OPENSSL_VERSION} ]]; then
	mkdir -p ${SCRIPT_PATH}/sources/

	install_packages "libtool zlib1g-dev libpcre3-dev libssl-dev libxslt1-dev libxml2-dev libgd-dev libgeoip-dev libgoogle-perftools-dev libperl-dev"

	cd ${SCRIPT_PATH}/sources
	wget_tar "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
	tar_file "openssl-${OPENSSL_VERSION}.tar.gz"
	cd openssl-${OPENSSL_VERSION}
	./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib shared zlib-dynamic -Wl,-R,'$(LIBRPATH)' -Wl,--enable-new-dtags >>"${make_log}" 2>>"${make_err_log}"

	make -j $(nproc) >>"${make_log}" 2>>"${make_err_log}"
	make install >>"${make_log}" 2>>"${make_err_log}"
fi
}
