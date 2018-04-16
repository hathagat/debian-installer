#!/bin/bash

check_nginx() {

source ${SCRIPT_PATH}/configs/userconfig.cfg  

greenb() { echo $(tput bold)$(tput setaf 2)${1}$(tput sgr0); }
ok="$(greenb [OKAY] -)"
redb() { echo $(tput bold)$(tput setaf 1)${1}$(tput sgr0); }
error="$(redb [ERROR] -)"

#check website
curl ${MYDOMAIN} -s -f -o /dev/null && echo "${ok} Website ${MYDOMAIN} is up and running." || echo "${error} Website ${MYDOMAIN} is down."

#check process
if pgrep -x "nginx" > /dev/null
then
    echo "${ok} Nginx is running"
else
    echo "${error} Nginx STOPPED"
fi

#check version
command="nginx -v"
nginxv=$( ${command} 2>&1 )
nginxvcut="echo ${nginxv:21}"
nginxlocal=$( ${nginxvcut} 2>&1 )

if [ $nginxlocal != ${NGINX_VERSION} ]; then
  echo "${error} The installed Nginx Version $nginxlocal is DIFFERENT with the Nginx Version ${NGINX_VERSION} defined in the Userconfig!"
else
	echo "${ok} The Nginx Version $nginxlocal is equal with the Nginx Version ${NGINX_VERSION} defined in the Userconfig!"
fi

#check vhost
if [ -e /etc/nginx/sites-available/${MYDOMAIN}.conf ]; then
  echo "${ok} Nginx vhost for ${MYDOMAIN} does exist"
else
  echo "${error} Nginx vhost for ${MYDOMAIN} does NOT exist"
fi

#check config
nginx -t >/dev/null 2>&1
ERROR=$?
if [ "$ERROR" = '0' ]; then
  echo "${ok} The Nginx Config is working."
else
  echo "${error} The Nginx Config is NOT working."
fi
}
