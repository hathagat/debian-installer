#!/bin/bash

install_system() {

trap error_exit ERR
timedatectl set-timezone ${TIMEZONE}

if [[ ${STATIC_IP} = "1" ]]; then
    cat > /etc/network/interfaces <<END
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto ${INTERFACE}
iface ${INTERFACE} inet static
    address ${CIDR}
    broadcast ${BROADCAST}
    gateway ${GATEWAY}
    dns-nameservers 146.185.167.43 46.182.19.48 194.150.168.168
    dns-search ${MYDOMAIN}
END
    update-rc.d dhcpcd remove
fi

# 146.185.167.43  - SecureDNS
# 46.182.19.48    - Digitalcourage
# 194.150.168.168 - AS250.net Foundation (CCC)
cat > /etc/resolv.conf <<END
domain ${MYDOMAIN}
search ${MYDOMAIN}
options rotate
options timeout:1
nameserver 146.185.167.43
nameserver 46.182.19.48
nameserver 194.150.168.168
END

ifdown ${INTERFACE} && ifup ${INTERFACE}

cat > /etc/apt/sources.list <<END
###### Debian Repos
deb http://deb.debian.org/debian/ stretch main contrib non-free
#deb-src http://deb.debian.org/debian/ stretch main contrib non-free

deb http://deb.debian.org/debian/ stretch-updates main contrib non-free
#deb-src http://deb.debian.org/debian/ stretch-updates main contrib non-free

deb http://deb.debian.org/debian-security stretch/updates main contrib non-free
#deb-src http://deb.debian.org/debian-security stretch/updates main contrib non-free

deb http://deb.debian.org/debian stretch-backports main contrib non-free
#deb-src http://deb.debian.org/debian stretch-backports main contrib non-free

###### Custom Repos
END

DEBIAN_FRONTEND=noninteractive apt-get -y -qq --allow-unauthenticated clean >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get -y -qq --allow-unauthenticated update >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get -y -qq --allow-unauthenticated upgrade >/dev/null 2>&1
#DEBIAN_FRONTEND=noninteractive apt-get -y --allow-unauthenticated dist-upgrade

#install_packages "sudo rkhunter needrestart debsecan debsums passwdqc"

#thanks to https://linuxacademy.com/howtoguides/posts/show/topic/19700-linux-security-and-server-hardening-part1
cat > /etc/sysctl.conf <<END
#disable IPv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
net.ipv6.conf.${INTERFACE}.disable_ipv6 = 1

# Avoid a smurf attack
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Turn on protection for bad icmp error messages
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Turn on syncookies for SYN flood attack protection
net.ipv4.tcp_syncookies = 1

# Turn on and log spoofed, source routed, and redirect packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# No source routed packets here
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# Turn on reverse path filtering
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Make sure no one can alter the routing tables
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

# Don't act as a router
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Turn on execshield for reducing worm or other automated remote attacks
kernel.randomize_va_space = 2

# Increase system file descriptor limit
fs.file-max = 65535

# Allow for more PIDs (Prevention of fork() failure error message)
kernel.pid_max = 65536

# Increase system IP port limits
net.ipv4.ip_local_port_range = 2000 65000

# Tuning Linux network stack to increase TCP buffer size. Set the max OS send buffer size (wmem) and receive buffer size (rmem) to 12 MB for queues on all protocols.
net.core.rmem_max = 8388608
net.core.wmem_max = 8388608

# set minimum size, initial size and max size
net.ipv4.tcp_rmem = 10240 87380 12582912
net.ipv4.tcp_wmem = 10240 87380 12582912

# Value to set for queue on the INPUT side when incoming packets are faster then the kernel process on them.
net.core.netdev_max_backlog = 5000

# For increasing transfer window, enable window scaling
net.ipv4.tcp_window_scaling = 1

###
kernel.core_uses_pid = 1
kernel.kptr_restrict = 2
kernel.sysrq = 0
net.ipv4.tcp_timestamps = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
kernel.yama.ptrace_scope = 1
END

sysctl -p >>"${main_log}" 2>>"${err_log}"
}
