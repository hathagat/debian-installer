#!/bin/bash
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

check_postfix() {

failed_postfix_checks=0
passed_postfix_checks=0

if [ -e /etc/postfix/main.cf ]; then
  passed_postfix_checks=$((passed_postfix_checks + 1))
else
  failed_postfix_checks=$((failed_postfix_checks + 1))
  echo "${error} main.cf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/postfix/master.cf ]; then
  passed_postfix_checks=$((passed_postfix_checks + 1))
else
  failed_postfix_checks=$((failed_postfix_checks + 1))
  echo "${error} master.cf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/postfix/submission_header_cleanup ]; then
  passed_postfix_checks=$((passed_postfix_checks + 1))
else
  failed_postfix_checks=$((failed_postfix_checks + 1))
  echo "${error} submission_header_cleanup does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/postfix/sql/accounts.cf ]; then
  passed_postfix_checks=$((passed_postfix_checks + 1))
else
  failed_postfix_checks=$((failed_postfix_checks + 1))
  echo "${error} accounts.cf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/postfix/sql/aliases.cf ]; then
  passed_postfix_checks=$((passed_postfix_checks + 1))
else
  failed_postfix_checks=$((failed_postfix_checks + 1))
  echo "${error} aliases.cf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/postfix/sql/domains.cf ]; then
  passed_postfix_checks=$((passed_postfix_checks + 1))
else
  failed_postfix_checks=$((failed_postfix_checks + 1))
  echo "${error} domains.cf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/postfix/sql/recipient-access.cf ]; then
  passed_postfix_checks=$((passed_postfix_checks + 1))
else
  failed_postfix_checks=$((failed_postfix_checks + 1))
  echo "${error} recipient-access.cf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/postfix/sql/sender-login-maps.cf ]; then
  passed_postfix_checks=$((passed_postfix_checks + 1))
else
  failed_postfix_checks=$((failed_postfix_checks + 1))
  echo "${error} sender-login-maps.cf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/postfix/sql/tls-policy.cf ]; then
  passed_postfix_checks=$((passed_postfix_checks + 1))
else
  failed_postfix_checks=$((failed_postfix_checks + 1))
  echo "${error} tls-policy.cf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/postfix/without_ptr ]; then
  passed_postfix_checks=$((passed_postfix_checks + 1))
else
  failed_postfix_checks=$((failed_postfix_checks + 1))
  echo "${error} without_ptr does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/postfix/postscreen_access ]; then
  passed_postfix_checks=$((passed_postfix_checks + 1))
else
  failed_postfix_checks=$((failed_postfix_checks + 1))
  echo "${error} postscreen_access does NOT exist" >>"${failed_checks_log}"
fi

echo "Postfix:"
echo "${ok} ${passed_postfix_checks} checks passed!"

if [[ "${failed_postfix_checks}" != "0" ]]; then
  echo "${error} ${failed_postfix_checks} check/s failed! Please check ${SCRIPT_PATH}/logs/failed_checks.log or consider a new installation!"
fi

check_service "postfix"
}
