#!/bin/bash
# Compatible with Ubuntu 16.04 Xenial and Debian 9.x Stretch
#
	# This program is free software; you can redistribute it and/or modify
    # it under the terms of the GNU General Public License as published by
    # the Free Software Foundation; either version 2 of the License, or
    # (at your option) any later version.

    # This program is distributed in the hope that it will be useful,
    # but WITHOUT ANY WARRANTY; without even the implied warranty of
    # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    # GNU General Public License for more details.

    # You should have received a copy of the GNU General Public License along
    # with this program; if not, write to the Free Software Foundation, Inc.,
    # 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#-------------------------------------------------------------------------------------------------------------

install_system() {

hostnamectl set-hostname --static mail

rm /etc/hosts
cat > /etc/hosts <<END
127.0.0.1   localhost
127.0.1.1   mail.domain.tld  mail

::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
END
sed -i "s/domain.tld/${MYDOMAIN}/g" /etc/hosts

echo $(hostname -f) > /etc/mailname
#echo -e "${IPADR} ${MYDOMAIN} $(echo ${MYDOMAIN} | cut -f 1 -d '.')" >> /etc/hosts

timedatectl set-timezone ${TIMEZONE}

rm /etc/apt/sources.list

if [[ ${DISTOS} == 'DEBIAN' ]]; then
cat > /etc/apt/sources.list <<END
#------------------------------------------------------------------------------#
#                   OFFICIAL DEBIAN REPOS                                      #
#------------------------------------------------------------------------------#

###### Debian Main Repos
deb http://deb.debian.org/debian/ stretch main contrib non-free
deb-src http://deb.debian.org/debian/ stretch main contrib non-free

deb http://deb.debian.org/debian/ stretch-updates main contrib non-free
deb-src http://deb.debian.org/debian/ stretch-updates main contrib non-free

deb http://deb.debian.org/debian-security stretch/updates main contrib non-free
deb-src http://deb.debian.org/debian-security stretch/updates main contrib non-free

#Backports
deb http://ftp.debian.org/debian stretch-backports main
deb-src http://ftp.debian.org/debian stretch-backports main
END
fi

if [[ ${DISTOS} == 'UBUNTU' ]]; then
cat > /etc/apt/sources.list <<END
#------------------------------------------------------------------------------#
#                            OFFICIAL UBUNTU REPOS                             #
#------------------------------------------------------------------------------#

###### Ubuntu Main Repos
deb http://de.archive.ubuntu.com/ubuntu/ xenial main restricted universe multiverse
deb-src http://de.archive.ubuntu.com/ubuntu/ xenial main restricted universe multiverse

###### Ubuntu Update Repos
deb http://de.archive.ubuntu.com/ubuntu/ xenial-security main restricted universe multiverse
deb http://de.archive.ubuntu.com/ubuntu/ xenial-updates main restricted universe multiverse
deb-src http://de.archive.ubuntu.com/ubuntu/ xenial-security main restricted universe multiverse
deb-src http://de.archive.ubuntu.com/ubuntu/ xenial-updates main restricted universe multiverse
END
fi

apt-get update -y >/dev/null 2>&1
apt-get -y upgrade >/dev/null 2>&1

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
kernel.randomize_va_space = 1

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
END

sysctl -p >>"${main_log}" 2>>"${err_log}"
}
