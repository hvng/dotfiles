#!/bin/bash

if [[ `lsb_release -is` == "Arch" ]]; then
    sudo pacman -Syu zsh --noconfirm
elif [[ `lsb_release -is` == "Ubuntu" ]]; then
    sudo apt-get install zsh -y
elif [[ `lsb_release -is` == "Fedora" ]]; then
    sudo dnf install zsh -y
fi

chsh -s /bin/zsh