#!/bin/bash
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

check_php() {

#check version
command=$(php -v)
phpv=$(echo $command | cut -c4-7)

if [ $phpv != ${PHPVERSION7} ]; then
  echo "${error} The installed PHP Version $phpv is DIFFERENT with the PHP Version ${PHPVERSION7} defined in the Userconfig!"
else
	echo "${ok} The PHP Version $phpv is equal with the PHP Version ${PHPVERSION7} defined in the Userconfig!"
fi

check_service "php$PHPVERSION7-fpm"
}
