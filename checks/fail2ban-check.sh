#!/bin/bash
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

check_fail2ban() {

failed_fail2ban_checks=0
passed_fail2ban_checks=0

if [ -e /etc/fail2ban/fail2ban.local ]; then
  passed_fail2ban_checks=$((passed_fail2ban_checks + 1))
else
  failed_fail2ban_checks=$((failed_fail2ban_checks + 1))
  echo "${error} fail2ban.local does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/fail2ban/jail.local ]; then
  passed_fail2ban_checks=$((passed_fail2ban_checks + 1))
else
  failed_fail2ban_checks=$((failed_fail2ban_checks + 1))
  echo "${error} jail.local does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/init.d/fail2ban ]; then
  passed_fail2ban_checks=$((passed_fail2ban_checks + 1))
else
  failed_fail2ban_checks=$((failed_fail2ban_checks + 1))
  echo "${error} fail2ban initd does NOT exist" >>"${failed_checks_log}"
fi

echo "Fail2ban:"
echo "${ok} ${passed_fail2ban_checks} checks passed!"

if [[ "${failed_fail2ban_checks}" != "0" ]]; then
  echo "${error} ${failed_fail2ban_checks} check/s failed! Please check ${SCRIPT_PATH}/logs/failed_checks.log or consider a new installation!"
fi

check_service "fail2ban"
}
