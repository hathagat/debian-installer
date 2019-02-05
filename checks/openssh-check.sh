#!/bin/bash
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

check_openssh() {

failed_openssh_checks=0
passed_openssh_checks=0

if [ -e /etc/ssh/sshd_config ]; then
  passed_openssh_checks=$((passed_openssh_checks + 1))
else
  failed_openssh_checks=$((failed_openssh_checks + 1))
  echo "${error} sshd_config does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/issue ]; then
  passed_openssh_checks=$((passed_openssh_checks + 1))
else
  failed_openssh_checks=$((failed_openssh_checks + 1))
  echo "${error} issue file does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/issue.net ]; then
  passed_openssh_checks=$((passed_openssh_checks + 1))
else
  failed_openssh_checks=$((failed_openssh_checks + 1))
  echo "${error} issue.net file does NOT exist" >>"${failed_checks_log}"
fi

if [ -e ~/.ssh/authorized_keys2 ]; then
  passed_openssh_checks=$((passed_openssh_checks + 1))
else
  failed_openssh_checks=$((failed_openssh_checks + 1))
  echo "${error} authorized_keys2 does NOT exist" >>"${failed_checks_log}"
fi

if [ -e ${SCRIPT_PATH}/ssh_privatekey.txt ]; then
  passed_openssh_checks=$((passed_openssh_checks + 1))
else
  failed_openssh_checks=$((failed_openssh_checks + 1))
  echo "${error} ssh_privatekey.txt does NOT exist" >>"${failed_checks_log}"
fi

echo "Openssh:"
echo "${ok} ${passed_openssh_checks} checks passed!"

if [[ "${failed_openssh_checks}" != "0" ]]; then
  echo "${error} ${failed_openssh_checks} check/s failed! Please check ${SCRIPT_PATH}/logs/failed_checks.log or consider a new installation!"
fi

check_service "sshd"
}
