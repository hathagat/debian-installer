#!/bin/bash
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

check_lets_encrypt() {

failed_lets_encrypt_checks=0
passed_lets_encrypt_checks=0

if [ -e /root/.acme.sh/${MYDOMAIN}_ecc/fullchain.cer ]; then
  passed_lets_encrypt_checks=$((passed_lets_encrypt_checks + 1))
else
  failed_lets_encrypt_checks=$((failed_lets_encrypt_checks + 1))
  echo "${error} fullchain.cer does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/nginx/ssl/${MYDOMAIN}-ecc.cer ]; then
  passed_lets_encrypt_checks=$((passed_lets_encrypt_checks + 1))
else
  failed_lets_encrypt_checks=$((failed_lets_encrypt_checks + 1))
  echo "${error} ${MYDOMAIN}-ecc.cer does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /root/.acme.sh/${MYDOMAIN}_ecc/${MYDOMAIN}.key ]; then
  passed_lets_encrypt_checks=$((passed_lets_encrypt_checks + 1))
else
  failed_lets_encrypt_checks=$((failed_lets_encrypt_checks + 1))
  echo "${error} ${MYDOMAIN}.key does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/nginx/ssl/${MYDOMAIN}-ecc.key ]; then
  passed_lets_encrypt_checks=$((passed_lets_encrypt_checks + 1))
else
  failed_lets_encrypt_checks=$((failed_lets_encrypt_checks + 1))
  echo "${error} ${MYDOMAIN}-ecc.key does NOT exist" >>"${failed_checks_log}"
fi

echo "Let's encrypt:"
echo "${ok} ${passed_lets_encrypt_checks} checks passed!"

if [[ "${failed_lets_encrypt_checks}" != "0" ]]; then
  echo "${error} ${failed_lets_encrypt_checks} check/s failed! Please check ${SCRIPT_PATH}/logs/failed_checks.log or consider a new installation!"
fi
}
