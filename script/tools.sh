#!/bin/bash

install_common() {

install_packages "htop vim tree"

if [[ ! -d ~/.vim_runtime ]]; then
    git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to clone vimrx"
fi
bash ~/.vim_runtime/install_basic_vimrc.sh >>"${main_log}" 2>>"${err_log}"

mkdir -p ~/.vim/syntax/
# web link: https://vim.sourceforge.io/scripts/script.php?script_id=1886
wget -O ~/.vim/syntax/nginx.vim https://vim.sourceforge.io/scripts/download_script.php?src_id=19394 >>"${main_log}" 2>>"${err_log}"
cat > ~/.vim/filetype.vim <<EOF
au BufRead,BufNewFile /etc/nginx/*,/usr/local/nginx/conf/*,/opt/nginx/* if &ft == '' | setfiletype nginx | endif
EOF

echo "Installing bash-it"
if [[ ! -d ~/.bash_it ]]; then
    git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to clone bash-it"
fi
~/.bash_it/install.sh --silent >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install bash-it"

bash -lic "bash-it enable plugin docker extract gh git history" >>"${main_log}" 2>>"${err_log}"
bash -lic "bash-it enable completion defaults docker docker-compose export gh git git_flow_avh makefile ssh kubectl maven" >>"${main_log}" 2>>"${err_log}"
sed -i "s/bobby/pure/g" ~/.bashrc

cat > ~/.bash_profile <<END
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
END

install_packages "unattended-upgrades"

sed -i 's_//Unattended-Upgrade::MailOnlyOnError "true";_Unattended-Upgrade::MailOnlyOnError "true";_g' /etc/apt/apt.conf.d/50unattended-upgrades
sed -i 's_//Unattended-Upgrade::Remove-Unused-Dependencies "false";_Unattended-Upgrade::Remove-Unused-Dependencies "true";_g' /etc/apt/apt.conf.d/50unattended-upgrades
sed -i 's_//Unattended-Upgrade::Automatic-Reboot "false";_Unattended-Upgrade::Automatic-Reboot "true";_g' /etc/apt/apt.conf.d/50unattended-upgrades
sed -i 's_//Unattended-Upgrade::Automatic-Reboot-Time "02:00";_Unattended-Upgrade::Automatic-Reboot-Time "05:00";_g' /etc/apt/apt.conf.d/50unattended-upgrades
sed -i 's_//Unattended-Upgrade::SyslogEnable "false";_Unattended-Upgrade::SyslogEnable "true";_g' /etc/apt/apt.conf.d/50unattended-upgrades

cat > /etc/apt/apt.conf.d/20auto-upgrades <<END
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::Unattended-Upgrade "1";
END

}

install_docker() {
    if [[ ! $(command -v docker) ]]; then
        curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add - >>"${main_log}" 2>>"${err_log}"
        cat >> /etc/apt/sources.list <<END

## Docker
deb [arch=amd64] https://download.docker.com/linux/debian buster stable
#deb-src [arch=amd64] https://download.docker.com/linux/debian buster stable

END
        DEBIAN_FRONTEND=noninteractive apt-get -y -qq --allow-unauthenticated update >/dev/null 2>&1
        install_packages "docker-ce"
    fi
    docker --version >>"${main_log}" 2>>"${err_log}"
}

install_docker_compose() {
    echo "Installing docker-compose"
    curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose >>"${main_log}" 2>>"${err_log}"
    chmod +x /usr/local/bin/docker-compose
    curl -L https://raw.githubusercontent.com/docker/compose/${DOCKER_COMPOSE_VERSION}/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose >>"${main_log}" 2>>"${err_log}"
    docker-compose --version >>"${main_log}" 2>>"${err_log}"
}
