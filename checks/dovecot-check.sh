#!/bin/bash
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

check_dovecot() {

failed_dovecot_checks=0
passed_dovecot_checks=0

if [ -e /etc/dovecot/dovecot.conf ]; then
  passed_dovecot_checks=$((passed_dovecot_checks + 1))
else
  failed_dovecot_checks=$((failed_dovecot_checks + 1))
  echo "${error} dovecot.conf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/dovecot/dovecot-sql.conf ]; then
  passed_dovecot_checks=$((passed_dovecot_checks + 1))
else
  failed_dovecot_checks=$((failed_dovecot_checks + 1))
  echo "${error} dovecot-sql.conf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /var/vmail/sieve/global/spam-global.sieve ]; then
  passed_dovecot_checks=$((passed_dovecot_checks + 1))
else
  failed_dovecot_checks=$((failed_dovecot_checks + 1))
  echo "${error} spam-global.sieve does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /var/vmail/sieve/global/learn-spam.sieve ]; then
  passed_dovecot_checks=$((passed_dovecot_checks + 1))
else
  failed_dovecot_checks=$((failed_dovecot_checks + 1))
  echo "${error} learn-spam.sieve does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /var/vmail/sieve/global/learn-ham.sieve ]; then
  passed_dovecot_checks=$((passed_dovecot_checks + 1))
else
  failed_dovecot_checks=$((failed_dovecot_checks + 1))
  echo "${error} learn-ham.sieve does NOT exist" >>"${failed_checks_log}"
fi

echo "Dovecot:"
echo "${ok} ${passed_dovecot_checks} checks passed!"

if [[ "${failed_dovecot_checks}" != "0" ]]; then
  echo "${error} ${failed_dovecot_checks} check/s failed! Please check ${SCRIPT_PATH}/logs/failed_checks.log or consider a new installation!"
fi

check_service "dovecot"
}
