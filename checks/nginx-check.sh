#!/bin/bash
# # Compatible with Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

check_nginx() {

failed_nginx_checks=0
passed_nginx_checks=0

if [ -e /etc/init.d/nginx ]; then
  passed_nginx_checks=$((passed_nginx_checks + 1))
else
  failed_nginx_checks=$((failed_nginx_checks + 1))
  echo "${error} nginx init does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/nginx/nginx.conf ]; then
  passed_nginx_checks=$((passed_nginx_checks + 1))
else
  failed_nginx_checks=$((failed_nginx_checks + 1))
  echo "${error} nginx.conf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/nginx/_general.conf ]; then
  passed_nginx_checks=$((passed_nginx_checks + 1))
else
  failed_nginx_checks=$((failed_nginx_checks + 1))
  echo "${error} _general.conf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/nginx/_pagespeed.conf ]; then
  passed_nginx_checks=$((passed_nginx_checks + 1))
else
  failed_nginx_checks=$((failed_nginx_checks + 1))
  echo "${error} _pagespeed.conf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/nginx/_php_fastcgi.conf ]; then
  passed_nginx_checks=$((passed_nginx_checks + 1))
else
  failed_nginx_checks=$((failed_nginx_checks + 1))
  echo "${error} _php_fastcgi.conf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/nginx/_brotli.conf ]; then
  passed_nginx_checks=$((passed_nginx_checks + 1))
else
  failed_nginx_checks=$((failed_nginx_checks + 1))
  echo "${error} _brotli.conf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /var/www/${MYDOMAIN}/public/NeXt-logo.jpg ]; then
  passed_nginx_checks=$((passed_nginx_checks + 1))
else
  failed_nginx_checks=$((failed_nginx_checks + 1))
  echo "${error} NeXt-logo.jpg does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /var/www/${MYDOMAIN}/public/index.html ]; then
  passed_nginx_checks=$((passed_nginx_checks + 1))
else
  failed_nginx_checks=$((failed_nginx_checks + 1))
  echo "${error} index.html does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/nginx/sites-enabled/${MYDOMAIN}.conf ]; then
  passed_nginx_checks=$((passed_nginx_checks + 1))
else
  failed_nginx_checks=$((failed_nginx_checks + 1))
  echo "${error} /sites-enabled/${MYDOMAIN}.conf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/nginx/sites-available/${MYDOMAIN}.conf ]; then
  passed_nginx_checks=$((passed_nginx_checks + 1))
else
  failed_nginx_checks=$((failed_nginx_checks + 1))
  echo "${error} /sites-available/${MYDOMAIN}.conf does NOT exist" >>"${failed_checks_log}"
fi

echo "Nginx:"
echo "${ok} ${passed_nginx_checks} checks passed!"

if [[ "${failed_nginx_checks}" != "0" ]]; then
  echo "${error} ${failed_nginx_checks} check/s failed! Please check ${SCRIPT_PATH}/logs/failed_checks.log or consider a new installation!"
fi

#check config
nginx -t >/dev/null 2>&1
ERROR=$?
if [ "$ERROR" = '0' ]; then
  echo "${ok} The Nginx Config is working."
else
  echo "${error} The Nginx Config is NOT working."
fi

#check version
command="nginx -v"
nginxv=$( ${command} 2>&1 )
nginxlocal=$(echo $nginxv | grep -o '[0-9.]*$')

if [ $nginxlocal != ${NGINX_VERSION} ]; then
  echo "${error} The installed Nginx Version $nginxlocal is DIFFERENT with the Nginx Version ${NGINX_VERSION} defined in the Userconfig!"
else
	echo "${ok} The Nginx Version $nginxlocal is equal with the Nginx Version ${NGINX_VERSION} defined in the Userconfig!"
fi

#check website
curl ${MYDOMAIN} -s -f -o /dev/null && echo "${ok} Website ${MYDOMAIN} is up and running." || echo "${error} Website ${MYDOMAIN} is down."

#check process
check_service "nginx"
}
