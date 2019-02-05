#!/bin/bash
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

check_mailserver() {

failed_mailserver_checks=0
passed_mailserver_checks=0

if [ -e /root/.acme.sh/mail.${MYDOMAIN}/fullchain.cer ]; then
  passed_mailserver_checks=$((passed_mailserver_checks + 1))
else
  failed_mailserver_checks=$((failed_mailserver_checks + 1))
  echo "${error} fullchain.cer mailserver does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/nginx/ssl/mail.${MYDOMAIN}.cer ]; then
  passed_mailserver_checks=$((passed_mailserver_checks + 1))
else
  failed_mailserver_checks=$((failed_mailserver_checks + 1))
  echo "${error} mail.${MYDOMAIN}.cer does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /root/.acme.sh/mail.${MYDOMAIN}/mail.${MYDOMAIN}.key ]; then
  passed_mailserver_checks=$((passed_mailserver_checks + 1))
else
  failed_mailserver_checks=$((failed_mailserver_checks + 1))
  echo "${error} mail.${MYDOMAIN}.key does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/nginx/ssl/mail.${MYDOMAIN}.key ]; then
  passed_mailserver_checks=$((passed_mailserver_checks + 1))
else
  failed_mailserver_checks=$((failed_mailserver_checks + 1))
  echo "${error} /etc/nginx/ssl/mail.${MYDOMAIN}.key does NOT exist" >>"${failed_checks_log}"
fi

echo "Mailserver:"
echo "${ok} ${passed_mailserver_checks} checks passed!"

if [[ "${failed_mailserver_checks}" != "0" ]]; then
  echo "${error} ${failed_mailserver_checks} check/s failed! Please check ${SCRIPT_PATH}/logs/failed_checks.log or consider a new installation!"
fi
}
