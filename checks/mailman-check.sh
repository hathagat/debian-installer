#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

check_mailman() {

failed_mailman_checks=0
passed_mailman_checks=0

if [ -e /etc/nginx/_mailman.conf ]; then
  passed_mailman_checks=$((passed_mailman_checks + 1))
else
  failed_mailman_checks=$((failed_mailman_checks + 1))
  echo "${error} _mailman.conf does NOT exist" >>"${failed_checks_log}"
fi

echo "Mailman:"
echo "${ok} ${passed_mailman_checks} checks passed!"

if [[ "${failed_mailman_checks}" != "0" ]]; then
  echo "${error} ${failed_mailman_checks} check/s failed! Please check ${SCRIPT_PATH}/logs/failed_checks.log or consider a new installation!"
fi
}
