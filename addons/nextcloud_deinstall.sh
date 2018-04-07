#!/bin/bash

deinstall_nextcloud() {

rm -r /srv/nextcloud/
rm /etc/nginx/html/${MYDOMAIN}/nextcloud
rm /etc/nginx/sites-custom/nextcloud.conf

service nginx restart

}
