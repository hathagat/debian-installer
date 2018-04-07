#!/bin/bash

update_openssl() {

source ${SCRIPT_PATH}/configs/versions.cfg

LOCAL_OPENSSL_VERSION_STRING=$(openssl version)
LOCAL_OPENSSL_VERSION=$(echo $LOCAL_OPENSSL_VERSION_STRING | cut -c9-14)

if [[ ${LOCAL_OPENSSL_VERSION} != ${OPENSSL_VERSION} ]]; then
	install_packages "libtool zlib1g-dev libpcre3-dev libssl-dev libxslt1-dev libxml2-dev libgd2-xpm-dev libgeoip-dev libgoogle-perftools-dev libperl-dev"

	mkdir -p ${SCRIPT_PATH}/sources/
	cd ${SCRIPT_PATH}/sources
	wget_tar "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
	tar_file "openssl-${OPENSSL_VERSION}.tar.gz"
	cd openssl-${OPENSSL_VERSION}

	./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib shared zlib-dynamic >>"${make_log}" 2>>"${make_err_log}"

	make -j $(nproc) >>"${make_log}" 2>>"${make_err_log}"
	make install >>"${make_log}" 2>>"${make_err_log}"
else
	dialog_info "No Openssl Update needed! Local Openssl Version: ${LOCAL_OPENSSL_VERSION}. Version to be installed: ${OPENSSL_VERSION}"
	exit 1
fi
}
