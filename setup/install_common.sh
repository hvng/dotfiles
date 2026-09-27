#!/bin/bash

case ${OSTYPE} in
    # For MacOS
    darwin*)
        echo "Hi MacOS!"
    brew install neovim ctags tmux htop xclip the_silver_searcher wget ripgrep
    ;;

    # For Linux
    linux*)
    if [[ `lsb_release -is` == "Arch" ]]; then
        sudo pacman -Syyu
        sudo pacman -Syu neovim ctags tmux htop xclip the_silver_searcher wget ripgrep --noconfirm

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
        sudo apt-get install universal-ctags tmux htop build-essential xclip silversearcher-ag curl ripgrep wget -y

        # init.lua needs Neovim >= 0.11, but apt ships an older one, so use the official release
        case $(uname -m) in
            x86_64) nvim_arch=x86_64 ;;
            aarch64|arm64) nvim_arch=arm64 ;;
        esac
        if [[ -n $nvim_arch ]]; then
            nvim_tar=/tmp/nvim-linux-$nvim_arch.tar.gz
            curl -fL -o "$nvim_tar" "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$nvim_arch.tar.gz" &&
                sudo rm -rf /opt/nvim &&
                sudo mkdir -p /opt/nvim &&
                sudo tar -xzf "$nvim_tar" -C /opt/nvim --strip-components=1 &&
                sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
            rm -f "$nvim_tar"
        fi
        command -v nvim >/dev/null || sudo apt-get install neovim -y

    elif [[ `lsb_release -is` == "Fedora" ]]; then
        sudo dnf install neovim ctags tmux htop xclip the_silver_searcher -y
    fi
    ;;
esac

