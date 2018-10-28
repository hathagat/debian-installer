<p align="center">
  <a href="https://nxt.sh/">
    <img src="https://nxt.sh/wp-content/uploads/2018/01/NeXt-logo.jpg">
  </a>

  <h3 align="center">NeXt-Server</h3>

  <p align="center">
    Debian Stretch Version of NeXt-Server Script.
    <br>
    <a href="https://github.com/shoujii/NeXt-Server/wiki"><strong>NeXt-Server Wiki »</strong></a>
    <br>
    <br>
    <a href="https://github.com/shoujii/NeXt-Server/issues/new">Report bug</a>
    ·
    <a href="https://nxt.sh/">Blog</a>
  </p>
</p>

<br>

## Table of contents

- [What you need](#what-you-need)
- [Quick start](#quick-start)
- [What's included](#whats-included)
- [Bugs and feature requests](#bugs-and-feature-requests)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [Creators](#creators)
- [Thanks](#thanks)
- [Used software](#used-software)
- [Copyright and license](#copyright-and-license)

## What you need:

A vServer with at least:
```
- 1 CPU Core
- 1 GB RAM
- KVM virtualized server (Openvz [...] will not work!)
- The latest "clean" Debian 9.x minimal installed on the server (with all updates!)
- rDNS set to the desired Domain
- root user access
- 9 GB free disk space

- IPv4 Adress
- A Domain and the ability to change the DNS Settings
- DNS Settings described in the dns_settings.txt
- Time... the DNS system may need 24 to 48 hours to recognize the changes you made!

- The will to learn something about Linux ;)
```

## Quick start

Several quick start options are available:

Install with [git]:
- `cd /root/; apt-get update; apt-get install git -y; git clone https://github.com/shoujii/NeXt-Server; cd NeXt-Server; bash nxt.sh
`

Read the [NeXt-Server Wiki](https://github.com/shoujii/NeXt-Server/wiki) for advanced information!

## What's included

Within the cloned repository you'll find the following directories and files, grouping the different installation files and configs in a logic structure. You'll see something like this:

```
NeXt-Server/
    ├── .github/
    │   ├── issue_template.md
    │
    ├── addons/
    │
    │   ├── vhosts/
        │   ├── [Various Vhost .conf files]
        │
    │   ├── [Various Addon .sh files]
    │
    ├── checks/
    │   ├── [Various check .sh files]
    │
    ├── configs/
    │   ├── arno-iptables-firewall/
    │   ├── dovecot/
    │   ├── fail2ban/
    │   ├── mailserver/
    │   ├── nginx/
    │   ├── php/
    │   ├── pma/
    │   ├── postfix/
    │   ├── rainloop/
    │   ├── rspamd/  
    │   ├── sshd_config  
    │   ├── userconfig.cfg
    │   ├── versions.cfg
    │
    ├── cronjobs/
    │   ├── backupscript
    │
    ├── includes/
    │   ├── NeXt-logo.jpg
    │   ├── dns_settings.txt
    │   ├── issue
    │   ├── issue.net
    │
    ├── logs/
    │   ├── error.log
    │   ├── failed_checks.log
    │   ├── main.log
    │   ├── make.log
    │   ├── make_error.log   
    │
    ├── menus/
    │   ├── [Various menu .sh files]
    │
    ├── script/
    │   ├── [Various script .sh files (main part of the script)]
    │
    ├── updates/
    │   ├── [Various service update .sh files]
    │
    ├── LICENSE
    ├── README.md
    ├── confighelper.sh
    ├── dns_settings.txt
    ├── install.sh
    ├── login_information.txt
    ├── nxt.sh
    ├── update_script.sh
```

## Bugs and feature requests

Have a bug or a feature request? Please first read the [issue guidelines]() and search for existing and closed issues. If your problem or idea is not addressed yet, [please open a new issue](https://github.com/shoujii/NeXt-Server/issues/new).


## Documentation

The NeXt-Server documentation, included in this repository in the docs directory, is also available on the [NeXt-Server Wiki](https://github.com/shoujii/NeXt-Server/wiki).

## Contributing

Please read through our [contributing guidelines](). Included are directions for opening issues, coding standards, and notes on development.

## Creators

**Marcel Gössel**

- <https://github.com/shoujii>

**René Wurch**

- <https://github.com/BoBBer446>


## Thanks

Thanks to [Thomas Leister] and his awesome Mailserver Setup, we're using in this Script!
(https://thomas-leister.de/mailserver-debian-stretch/)


Also thanks to [Michael Thies], for the managevmail script, used for the Mailserver.
(https://github.com/mhthies/managevmail)

## Used software
- Nginx                      <https://github.com/nginx/nginx>
- Openssh                    <https://github.com/openssh/openssh-portable>
- Openssl                    <https://github.com/openssl/openssl>
- Dovecot                    <https://github.com/dovecot/core>
- Postfix                    <http://www.postfix.org/>
- fail2ban                   <https://github.com/fail2ban/fail2ban>
- Arno's iptables firewall   <https://github.com/arno-iptables-firewall/aif>
- MariaDB                    <https://github.com/MariaDB/server>
- acme.sh                    <https://github.com/Neilpang/acme.sh>
- unbound                    <https://github.com/NLnetLabs/unbound>

## Copyright and license

Code and documentation copyright 2017-2018 the [NeXt-Server Authors](https://github.com/shoujii/NeXt-Server/graphs/contributors)
Code released under the [GNU General Public License v3.0](https://github.com/shoujii/NeXt-Server/blob/master/LICENSE).
