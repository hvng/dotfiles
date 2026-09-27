#!/bin/bash

# Installs Node.js + npm
if [[ `lsb_release -is` == "Arch" ]]; then
    sudo pacman -S nodejs npm --noconfirm
elif [[ `lsb_release -is` == "Ubuntu" ]]; then
    sudo apt-get install nodejs npm -y
elif [[ `lsb_release -is` == "Fedora" ]]; then
    sudo dnf install nodejs npm -y
else
    echo "Not supported, please install Node.js manually."
fi
