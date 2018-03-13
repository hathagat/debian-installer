#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

install_monit() {
apt-get install monit -y

systemctl start monit
systemctl enable monit

sed -i "s/# set httpd port 2812 and/set httpd port 2812 and/g" /etc/monit/monitrc
sed -i "s/# allow admin:monit/allow admin:monit/g" /etc/monit/monitrc



cat >> /etc/nginx/sites-custom/monit.conf << END
location /monit/ {

          proxy_pass http://127.0.0.1:2812;
          proxy_set_header Host $host;
          rewrite ^/monit/(.*) /$1 break;
          proxy_ignore_client_abort on;
  }
END

ln -s /etc/monit/conf-available/openssh-server /etc/monit/conf-enabled/
ln -s /etc/monit/conf-available/nginx /etc/monit/conf-enabled/
ln -s /etc/monit/conf-available/mysql /etc/monit/conf-enabled/
ln -s /etc/monit/conf-available/postfix /etc/monit/conf-enabled/
ln -s /etc/monit/conf-available/cron /etc/monit/conf-enabled/
ln -s /etc/monit/conf-available/rsyslog /etc/monit/conf-enabled/
ln -s /etc/monit/conf-available/smartmontools /etc/monit/conf-enabled/

systemctl restart monit
service nginx reload

}
