#!/bin/bash

# Detect the package manager
if command -v pacman &>/dev/null; then
    package_manager="pacman"
elif command -v dnf &>/dev/null; then
    package_manager="dnf"
elif command -v apt &>/dev/null; then
    package_manager="apt"
else
    echo "No supported package manager found. Exiting."
    exit 1
fi

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

# Detect NVIDIA GPU
if command -v lspci &>/dev/null; then
    gpu_info=$(lspci | grep -i NVIDIA)
    if [ -n "$gpu_info" ]; then
        has_nvidia_gpu=true
    fi
fi

# Install NVIDIA drivers if NVIDIA GPU is detected
if [ "$has_nvidia_gpu" = true ]; then
    echo "NVIDIA GPU detected. Installing proprietary drivers..."
    if [ "$package_manager" == "pacman" ]; then
        sudo pacman -S --noconfirm nvidia
    elif [ "$package_manager" == "dnf" ]; then
        sudo dnf install -y akmod-nvidia
    elif [ "$package_manager" == "apt" ]; then
        sudo ubuntu-drivers autoinstall
    fi
fi

# Install additional packages
echo "Installing packages"
if [ "$package_manager" == "pacman" ]; then
    sudo pacman -S --noconfirm flatpak firefox chromium yay swaylock waybar
    yay -Syyu --noconfirm ly steam discord protonup-qt protontricks swayfx sway swaybg-git foot gnome-polkit swaylock waybar swaync rofi wofi blueman cdrtools dvd+rw-tools networkmanager-openconnect xournalpp kicad kicad-library kicad-library-3d python-kikit python-pcbnewtransition texlive-most texlive-lang texlive-bibtexextra texlive-fontsextra thunar tumbler thunar-archive-plugin thunar-media-tags-plugin ark unarchiver electrum noto-fonts noto-fonts-cjk noto-fonts-extra virtualbox virtualbox-host-dkms virtualbox-guest-iso alsa-utils gtk-layer-shell zram-generator keepassxc qutebrowser brightnessctl lximage-qt wireplumber scrcpy intel-media-sdk openssl openssl-1.1 intel-media-driver intel-gpu-tools vulkan-intel libva-utils telegram-desktop vulkan-icd-loader vulkan-tools xorg-xrdb strawberry sof-firmware github-cli docker docker-compose openscad skanlite libvncserver remmina wayvnc exfatprogs nfs-utils tmux screen dex ddcutil i2c-tools archiso thunderbird bluez bluez-utils pacman-contrib smartmontools hdparm wayland-protocols hyphen-en hyphen gnome-keyring libgnome-keyring upower iotop f2fs-tools efitools efibootmgr dosfstools arch-install-scripts ruby-bundler pv alsa-firmware pipewire pipewire-alsa pipewire-jack pipewire-pulse xdg-desktop-portal xdg-desktop-portal-wlr yt-dlp mc translate-shell nm-connection-editor hunspell hunspell-en_us perl-file-mimeinfo sway swaybg swayidle mousepad cups cups-pdf usbutils inkscape go zsh i7z libappindicator-gtk3 lm_sensors stalonetray network-manager-applet gst-libav gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly tor pigz pbzip2 android-udev libmad opus flac pcmanfm-qt speedtest-cli fzf tree broot lxappearance qt5-wayland noto-fonts-emoji acpi systembus-notify ttf-dejavu otf-font-awesome xmlto pahole inetutils bc terminus-font reflector rsync cronie wf-recorder imagemagick tk python-pip zathura zathura-djvu zathura-pdf-mupdf udiskie udisks2 htop qt5ct qt6ct meson ninja scdoc playerctl libreoffice-fresh xorg-server-xwayland ffmpeg jdk-openjdk jdk8-openjdk mpv imv openssh wget ttf-opensans git neofetch pavucontrol grim slurp jq wl-clipboard neofetch android-tools cpio lhasa lzop p7zip unace unrar unzip zip earlyoom highlight mediainfo odt2txt perl-image-exiftool
elif [ "$package_manager" == "dnf" ]; then
echo "Installing Nix package manager"
    sh <(curl -L https://nixos.org/nix/install) --daemon
echo "Installing programs"
    sudo dnf install -y flatpak firefox chromium steam discord
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install -y net.davidotek.pupgui2 protontricks
elif [ "$package_manager" == "apt" ]; then
echo "Installing Nix package manager"
    sh <(curl -L https://nixos.org/nix/install) --daemon
echo "Installing Programs"
    sudo apt install -y flatpak firefox chromium-browser
    flatpak install -y net.davidotek.pupgui2 protontricks
fi

# Clone GitHub repository and copy files to home folder
echo "Cloning GitHub repository and copying files to home folder..."
cd /home/$USER/
git clone https://github.com/hamburgerghini1/garuda_dotfiles_2023
cd garuda_dotfiles_2023/
cp -r .config/ ~/.
cp -r .icons/ ~/.
cp -r .themes/ ~/.


echo "Script execution completed."
