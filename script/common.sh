#!/bin/bash

install_common() {

# Tools
install_packages "curl htop vim"

git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to clone vimrx"
bash ~/.vim_runtime/install_basic_vimrc.sh >>"${main_log}" 2>>"${err_log}"

# Bash
git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to clone bash-it"
~/.bash_it/install.sh --silent >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install bash-it"

. ~/.bashrc
. bash-it enable plugin docker extract gh git history >>"${main_log}" 2>>"${err_log}"
. bash-it enable completion defaults docker docker-compose export gh git git_flow_avh makefile ssh kubectl maven >>"${main_log}" 2>>"${err_log}"
sed -i "s/bobby/pure/g" ~/.bashrc
. ~/.bashrc

cat > ~/.bash_profile <<END
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
END

# Updates
apt-get -y install unattended-upgrades >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install unattended-upgrades"

sed -i 's_//      "o=Debian,n=jessie";_      "o=Debian,n=stretch";_g' /etc/apt/apt.conf.d/50unattended-upgrades
sed -i 's_//      "o=Debian,n=jessie-updates";_      "o=Debian,n=stretch-updates";_g' /etc/apt/apt.conf.d/50unattended-upgrades
sed -i 's_//      "o=Debian,n=jessie-proposed-updates";_      "o=Debian,n=stretch-proposed-updates";_g' /etc/apt/apt.conf.d/50unattended-upgrades
sed -i 's_//      "o=Debian,n=jessie,l=Debian-Security";_      "o=Debian Backports,n=stretch-backports";_g' /etc/apt/apt.conf.d/50unattended-upgrades
sed -i 's_//Unattended-Upgrade::MailOnlyOnError "true";_Unattended-Upgrade::MailOnlyOnError "true";_g' /etc/apt/apt.conf.d/50unattended-upgrades
sed -i 's_//Unattended-Upgrade::Remove-Unused-Dependencies "false";_Unattended-Upgrade::Remove-Unused-Dependencies "true";_g' /etc/apt/apt.conf.d/50unattended-upgrades
sed -i 's_//Unattended-Upgrade::Automatic-Reboot "false";_Unattended-Upgrade::Automatic-Reboot "true";_g' /etc/apt/apt.conf.d/50unattended-upgrades
sed -i 's_//Unattended-Upgrade::Automatic-Reboot-Time "02:00";_Unattended-Upgrade::Automatic-Reboot-Time "05:00";_g' /etc/apt/apt.conf.d/50unattended-upgrades

cat > /etc/apt/apt.conf.d/20auto-upgrades <<END
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::Unattended-Upgrade "1";
END

}

install_docker() {
    if command_exists docker; then
        echo "Docker already installed!"
    else
        install_packages "apt-transport-https ca-certificates curl gnupg2"
        curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -
        cat >> /etc/apt/sources.list <<END
# Docker
deb [arch=amd64] https://download.docker.com/linux/debian stretch stable
#deb-src [arch=amd64] https://download.docker.com/linux/debian stretch stable

END
        DEBIAN_FRONTEND=noninteractive apt-get -y -qq --allow-unauthenticated update >/dev/null 2>&1
        install_packages "docker-ce"
    fi
    mkdir -p ${DOCKER_DATA_PATH}
    echo
    docker --version
}

install_docker_compose() {
    curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    curl -L https://raw.githubusercontent.com/docker/compose/${DOCKER_COMPOSE_VERSION}/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
    echo
    docker-compose --version
}
