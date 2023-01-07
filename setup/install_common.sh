#!/bin/bash

case ${OSTYPE} in
    # For MacOS
    darwin*)
        echo "Hi MacOS!"
    brew install neovim ctags tmux htop xclip the_silver_searcher wget
    ;;

    # For Linux
    linux*)
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
        sudo apt-get update -y
        sudo apt-get install neovim universal-ctags tmux htop build-essential xclip silversearcher-ag curl -y

    elif [[ `lsb_release -is` == "Fedora" ]]; then
        sudo dnf install neovim ctags tmux htop xclip the_silver_searcher -y
    fi       
    ;;
esac

