#!/bin/bash

# Ask for the package manager
echo "Which package manager do you have? (pacman, apt, or dnf):"
read package_manager

# Update system based on package manager
if [ "$package_manager" == "pacman" ]; then
    # Set the fastest mirror
    sudo pacman-mirrors --fasttrack && sudo pacman -Syy

    # Update the whole system
    sudo pacman -Syu
elif [ "$package_manager" == "dnf" ]; then
    # Ask if rpm-fusion should be installed
    echo "Do you want to install rpm-fusion? (Yes/No):"
    read install_rpm_fusion

    # Set fastest mirror and configure dnf with defaultyes=True option
    sudo dnf config-manager --setopt=fastestmirror=True --save
    sudo sed -i '/^module_platform_id/s/$/ defaultyes=True/' /etc/dnf/dnf.conf

    # Update the whole system
    sudo dnf upgrade -y

    # Install rpm-fusion if chosen
    if [ "$install_rpm_fusion" == "Yes" ]; then
        sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    fi
elif [ "$package_manager" == "apt" ]; then
    # Update the system
    sudo apt update && sudo apt upgrade -y
else
    echo "Invalid package manager specified. Exiting."
    exit 1
fi

# Install additional packages
echo "Installing packages: flatpak, firefox, chromium"
if [ "$package_manager" == "pacman" ]; then
    sudo pacman -S --noconfirm flatpak firefox chromium yay
elif [ "$package_manager" == "dnf" ]; then
    sudo dnf install -y flatpak firefox chromium
elif [ "$package_manager" == "apt" ]; then
    sudo apt install -y flatpak firefox chromium-browser
fi

# Clone GitHub repository and copy files to home folder
echo "Cloning GitHub repository and copying files to home folder..."
git clone https://github.com/hamburgerghini1/garuda_dotfiles_2023
cp -r garuda_dotfiles_2023/* ~/.

echo "Script execution completed."
