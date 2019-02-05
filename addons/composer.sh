#!/bin/bash
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_composer() {

trap error_exit ERR

cd ${SCRIPT_PATH}/sources/ >>"${main_log}" 2>>"${err_log}"

EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
then
    >&2 echo 'ERROR: Invalid installer signature'
    rm composer-setup.php
    exit 1
fi

php composer-setup.php >>"${main_log}" 2>>"${err_log}"
php -r "unlink('composer-setup.php');" >>"${main_log}" 2>>"${err_log}"
mv composer.phar /usr/local/bin/composer >>"${main_log}" 2>>"${err_log}"

sed -i 's/COMPOSER_IS_INSTALLED="0"/COMPOSER_IS_INSTALLED="1"/' ${SCRIPT_PATH}/configs/userconfig.cfg
}
