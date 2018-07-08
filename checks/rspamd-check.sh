#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

check_rspamd() {

failed_rspamd_checks=0
passed_rspamd_checks=0

if [ -e /etc/apt/sources.list.d/rspamd.list ]; then
  passed_rspamd_checks=$((passed_rspamd_checks + 1))
else
  failed_rspamd_checks=$((failed_rspamd_checks + 1))
  echo "${error} rspamd.list does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/rspamd/local.d/options.inc ]; then
  passed_rspamd_checks=$((passed_rspamd_checks + 1))
else
  failed_rspamd_checks=$((failed_rspamd_checks + 1))
  echo "${error} options.inc does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/rspamd/local.d/worker-normal.inc ]; then
  passed_rspamd_checks=$((passed_rspamd_checks + 1))
else
  failed_rspamd_checks=$((failed_rspamd_checks + 1))
  echo "${error} worker-normal.inc does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/rspamd/local.d/classifier-bayes.conf ]; then
  passed_rspamd_checks=$((passed_rspamd_checks + 1))
else
  failed_rspamd_checks=$((failed_rspamd_checks + 1))
  echo "${error} classifier-bayes.conf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/rspamd/local.d/worker-controller.inc ]; then
  passed_rspamd_checks=$((passed_rspamd_checks + 1))
else
  failed_rspamd_checks=$((failed_rspamd_checks + 1))
  echo "${error} worker-controller.inc does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/rspamd/local.d/worker-proxy.inc ]; then
  passed_rspamd_checks=$((passed_rspamd_checks + 1))
else
  failed_rspamd_checks=$((failed_rspamd_checks + 1))
  echo "${error} worker-proxy.inc does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/rspamd/local.d/logging.inc ]; then
  passed_rspamd_checks=$((passed_rspamd_checks + 1))
else
  failed_rspamd_checks=$((failed_rspamd_checks + 1))
  echo "${error} logging.inc does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/rspamd/local.d/milter_headers.conf ]; then
  passed_rspamd_checks=$((passed_rspamd_checks + 1))
else
  failed_rspamd_checks=$((failed_rspamd_checks + 1))
  echo "${error} milter_headers.conf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /var/lib/rspamd/dkim/${CURRENT_YEAR}.key ]; then
  passed_rspamd_checks=$((passed_rspamd_checks + 1))
else
  failed_rspamd_checks=$((failed_rspamd_checks + 1))
  echo "${error} ${CURRENT_YEAR}.key does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /var/lib/rspamd/dkim/${CURRENT_YEAR}.txt ]; then
  passed_rspamd_checks=$((passed_rspamd_checks + 1))
else
  failed_rspamd_checks=$((failed_rspamd_checks + 1))
  echo "${error} ${CURRENT_YEAR}.txt does NOT exist" >>"${failed_checks_log}"
fi

if [ -e ${SCRIPT_PATH}/DKIM_KEY_ADD_TO_DNS.txt ]; then
  passed_rspamd_checks=$((passed_rspamd_checks + 1))
else
  failed_rspamd_checks=$((failed_rspamd_checks + 1))
  echo "${error} DKIM_KEY_ADD_TO_DNS.txt does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/rspamd/local.d/dkim_signing.conf ]; then
  passed_rspamd_checks=$((passed_rspamd_checks + 1))
else
  failed_rspamd_checks=$((failed_rspamd_checks + 1))
  echo "${error} dkim_signing.conf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/rspamd/local.d/redis.conf ]; then
  passed_rspamd_checks=$((passed_rspamd_checks + 1))
else
  failed_rspamd_checks=$((failed_rspamd_checks + 1))
  echo "${error} redis.conf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/nginx/_rspamd.conf ]; then
  passed_rspamd_checks=$((passed_rspamd_checks + 1))
else
  failed_rspamd_checks=$((failed_rspamd_checks + 1))
  echo "${error} _rspamd.conf does NOT exist" >>"${failed_checks_log}"
fi

echo "Rspamd:"
echo "${ok} ${passed_rspamd_checks} checks passed!"

if [[ "${failed_rspamd_checks}" != "0" ]]; then
  echo "${error} ${failed_rspamd_checks} check/s failed! Please check ${SCRIPT_PATH}/logs/failed_checks.log or consider a new installation!"
fi

check_service "rspamd"
check_service "redis-server"
}
