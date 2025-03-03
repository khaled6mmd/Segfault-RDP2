#!/bin/bash

# Set default values
username="user"
password="root"
kernel_version="linux-image-6.11.2-amd64"
chrome_remote_desktop_url="https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb"

# Function to log messages
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Function to install packages
install_package() {
    package_url=$1
    log "Downloading $package_url"
    wget -q --show-progress "$package_url"
    log "Installing $(basename $package_url)"
    sudo dpkg --install $(basename $package_url)
    log "Fixing broken dependencies"
    sudo apt-get install --fix-broken -y
    rm $(basename $package_url)
}

# Installation steps
log "Starting installation"

# Update package lists
log "Updating package lists"
sudo apt update -y

# Install Kernel
log "Installing new kernel: $kernel_version"
sudo apt install -y "$kernel_version"

# Create user
log "Creating user '$username'"
sudo useradd -m "$username"
echo "$username:$password" | sudo chpasswd
sudo sed -i 's/\/bin\/sh/\/bin\/bash/g' /etc/passwd

# Install Chrome Remote Desktop
install_package "$chrome_remote_desktop_url"

# Install XFCE desktop environment
log "Installing XFCE desktop environment"
sudo DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes -y xfce4 desktop-base dbus-x11 xscreensaver

# Set up Chrome Remote Desktop session
log "Setting up Chrome Remote Desktop session"
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session'

# Disable lightdm service
log "Disabling lightdm service"
sudo systemctl disable lightdm.service

# Install Firefox ESR
log "Installing Firefox ESR"
sudo apt update
sudo add-apt-repository ppa:mozillateam/ppa
sudo apt update
sudo apt install -y firefox-esr

# Install VirtualBox
log "Installing VirtualBox"
sudo apt install -y virtualbox

log "Installation completed successfully"

# Prompt for reboot
read -p "Kernel installed. A reboot is required. Do you want to reboot now? (y/n): " reboot_now
if [ "$reboot_now" = "y" ] || [ "$reboot_now" = "Y" ]; then
    log "Rebooting system"
    sudo reboot
else
    log "Please reboot manually to apply kernel changes."
fi
