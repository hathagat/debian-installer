#!/bin/bash
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

check_unbound() {

failed_unbound_checks=0
passed_unbound_checks=0

if [ -e /etc/resolvconf/resolv.conf.d/head ]; then
  passed_unbound_checks=$((passed_unbound_checks + 1))
else
  failed_unbound_checks=$((failed_unbound_checks + 1))
  echo "${error} head file does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/unbound/unbound.conf ]; then
  passed_unbound_checks=$((passed_unbound_checks + 1))
else
  failed_unbound_checks=$((failed_unbound_checks + 1))
  echo "${error} unbound.conf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /var/lib/unbound/root.key ]; then
  passed_unbound_checks=$((passed_unbound_checks + 1))
else
  failed_unbound_checks=$((failed_unbound_checks + 1))
  echo "${error} root.key does NOT exist" >>"${failed_checks_log}"
fi

echo "Unbound:"
echo "${ok} ${passed_unbound_checks} checks passed!"

if [[ "${failed_unbound_checks}" != "0" ]]; then
  echo "${error} ${failed_unbound_checks} check/s failed! Please check ${SCRIPT_PATH}/logs/failed_checks.log or consider a new installation!"
fi

check_service "unbound"
}
