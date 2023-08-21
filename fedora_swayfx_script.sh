#!/bin/bash

# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
  echo "This script requires superuser privileges. Please run it with sudo."
  exit 1
fi

# Setup dnf and RPMFusion
dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Add necessary copr repos
dnf copr enable erikreider/SwayNotificationCenter
dnf copr enable swayfx/swayfx
dnf copr enable tofik/nwg-shell

# Adding defaultyes option in dnf config
sed -i '/\[main\]/a defaultyes=True' /etc/dnf/dnf.conf

# Installing programs from dnf
dnf install make automake fuzzel grim slurp gcc gcc-c++ zsh kernel-devel pam-devel libxcb-devel alacritty wofi swayfx fish nwg-shell SwayNotificationCenter waybar clipman wl-clipboard kanshi micro playerctl wofi rofi google-noto-fonts-common swaylock swayidle dex feh

# Installing flatpak (just in case if it's not installed) and enable flathub
dnf install flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Installing flatpaks I use most
flatpak install obs kdenlive lutris bottles gimp protontricks flatseal easyeffects spotify spotube audacity lmms code io.github.shiftey.Desktop net.davidotek.pupgui2

# Cloning dotfiles to documents folder
mkdir /home/tommi/Documents/GitHub
cd /home/tommi/Documents/GitHub
git clone https://github.com/hamburgerghini1/garuda_dotfiles_2023
cd garuda_dotfiles_2023

# Moving dotfiles to home folder
cp -r .bashrc /home/tommi
cp -r .icons /home/tommi
cp -r .local /home/tommi
cp -r .config /home/tommi
cp -r Pictures  /home/tommi
cp -r .themes /home/tommi
cp -r .zshrc /home/tommi

# Cloning ly display manager repo and compiling it
git clone --recurse-submodules https://github.com/fairyglade/ly
cd ly
make
make run
make install installsystemd
systemctl enable ly.service
systemctl disable getty@tty2.service

# Installing python 3.12 as a depedency
cd /usr/src
wget https://www.python.org/ftp/python/3.12.0/Python-3.12.0rc1.tgz
tar xzf Python-3.11.3.tgz
cd Python-3.11.3 
sudo ./configure --enable-optimizations 
sudo make altinstall
sudo rm /usr/src/Python-3.11.3.tgz 

# Cloning sway-interactive-screenshot repo and compiling it
cd /home/tommi/Ducuments/GitHub
git clone https://github.com/moverest/sway-interactive-screenshot
chmod +x sway-interactive-screenshot
./sway-interactive-screenshot

# reboot
reboot
