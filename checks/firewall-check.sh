#!/bin/bash
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

check_firewall() {

failed_firewall_checks=0
passed_firewall_checks=0
#### not finished yet ####

if [ -e /etc/arno-iptables-firewall/firewall.conf ]; then
  passed_firewall_checks=$((passed_firewall_checks + 1))
else
  failed_firewall_checks=$((failed_firewall_checks + 1))
  echo "${error} firewall.conf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/cron.daily/blocked-hosts ]; then
  passed_firewall_checks=$((passed_firewall_checks + 1))
else
  failed_firewall_checks=$((failed_firewall_checks + 1))
  echo "${error} blocked-hosts does NOT exist" >>"${failed_checks_log}"
fi

echo "Firewall:"
echo "${ok} ${passed_firewall_checks} checks passed!"

if [[ "${failed_firewall_checks}" != "0" ]]; then
  echo "${error} ${failed_firewall_checks} check/s failed! Please check ${SCRIPT_PATH}/logs/failed_checks.log or consider a new installation!"
fi

check_service "arno-iptables-firewall"
}
