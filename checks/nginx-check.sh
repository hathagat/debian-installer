#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

check_nginx() {

#check process
if pgrep -x "nginx" > /dev/null
then
    echo "Nginx is running"
else
    echo "Nginx STOPPED"
fi

#check version
command="nginx -v"
nginxv=$( ${command} 2>&1 )
nginxvcut="echo ${nginxv:21}"
nginxlocal=$( ${nginxvcut} 2>&1 )

if [[ $nginxlocal != ${NGINX_VERSION} ]]; then
  echo "The Nginx Version is DIFFERENT with the Nginx Version defined in the Userconfig!"
else
	echo "The Nginx Version is equal with the Nginx Version defined in the Userconfig!"
fi

#check vhost
if [ -e /etc/nginx/sites-available/${MYDOMAIN}.conf ]; then
  echo "Nginx vhost for ${MYDOMAIN} does exist"
else
  echo "Nginx vhost for ${MYDOMAIN} does NOT exist"
fi

#check config
nginx -t >/dev/null 2>&1
ERROR=$?
if [ "$ERROR" = '0' ]; then
  echo "The Nginx Config is working."
else
  echo "The Nginx Config is NOT working."
fi
}
