#!/bin/bash

if [[ `lsb_release -is` == "Arch" ]]; then
    sudo pacman -Syyu
    sudo pacman -Syu neovim ctags tmux htop xclip the_silver_searcher wget --noconfirm

    # install yay
    pacman -Q yay
    if [[ $? -eq 0 ]]; then
        echo "Yay is already installed"
    else
        echo "Installing yay..."
        git clone https://aur.archlinux.org/yay-git.git /tmp/yay-git
        cd /tmp/yay-git
        makepkg -si
        yay -Syu
        echo "DONE"
    fi

elif [[ `lsb_release -is` == "Ubuntu" ]]; then
    sudo apt update
    sudo apt install neovim ctags tmux htop build-essential xclip silversearcher-ag curl -y

elif [[ `lsb_release -is` == "Fedora" ]]; then
    sudo dnf install neovim ctags tmux htop xclip the_silver_searcher -y
fi