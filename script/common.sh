#!/bin/bash

install_common() {

# Tools
apt-get -y install curl htop vim >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to install common packages"

git clone --depth=1 git://github.com/amix/vimrc.git ~/.vim_runtime >>"${main_log}" 2>>"${err_log}" || error_exit "Failed to clone vimrx"
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
