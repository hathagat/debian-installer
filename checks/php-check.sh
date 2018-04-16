#!/bin/bash

check_php() {

source ${SCRIPT_PATH}/configs/userconfig.cfg  

greenb() { echo $(tput bold)$(tput setaf 2)${1}$(tput sgr0); }
ok="$(greenb [OKAY] -)"
redb() { echo $(tput bold)$(tput setaf 1)${1}$(tput sgr0); }
error="$(redb [ERROR] -)"

#check process
if pgrep "php" > /dev/null
then
    echo "${ok} PHP is running"
else
    echo "${error} PHP STOPPED"
fi

#check version
command=$(php -v)
phpv=$(echo $command | cut -c4-7)

if [ $phpv != ${PHPVERSION7} ]; then
  echo "${error} The installed PHP Version $phpv is DIFFERENT with the PHP Version ${PHPVERSION7} defined in the Userconfig!"
else
	echo "${ok} The PHP Version $phpv is equal with the PHP Version ${PHPVERSION7} defined in the Userconfig!"
fi

}
