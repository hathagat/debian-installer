#What you need:

A vServer with at least:
```
- 1 CPU Core
- 1 GB RAM
- KVM virtualized server (Openvz [...] will not work!)
- The latest "clean" Debian 9.x minimal installed on the server
- rDNS set to the desired Domain
- root user access
- 9 GB free disk space

- IPv4 Adress
- A Domain and the ability to change the DNS Settings
- DNS Settings described in the dns_settings.txt
- Time... the DNS system may needs 24 to 48 hours to recognize the changes you made!

- The will to learn something about Linux ;)
```

#Short instructions:

```
cd /root/; apt-get update; apt-get install git -y; git clone https://github.com/shoujii/NeXt-Server; cd NeXt-Server; bash nxt.sh
```

Follow the instructions!






#Used software and credits:
```
#Thanks to Thomas Leister and his awesome Mailserver Setup, we're using in this Script!
https://thomas-leister.de/mailserver-debian-stretch/

#Mailman by phiilu
https://github.com/phiilu/mailman

#Rainloop
https://github.com/RainLoop/rainloop-webmail/

#phpmyadmin
https://github.com/phpmyadmin/phpmyadmin

#openssl
https://github.com/openssl/openssl

#openssh
https://github.com/openssh/openssh-portable

#nginx
https://github.com/nginx/nginx

#fail2ban
https://github.com/fail2ban/fail2ban

#Arno's iptables firewall
https://github.com/arno-iptables-firewall/aif
```
