#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

delete_nextcloud() {

rm -r /srv/nextcloud/
rm /etc/nginx/html/${MYDOMAIN}/nextcloud
rm /etc/nginx/sites-custom/nextcloud.conf

service nginx restart

}
