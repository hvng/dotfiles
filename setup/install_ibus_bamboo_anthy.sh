#!/bin/bash

if [[ `lsb_release -is` == "Arch" ]]; then
    sudo pacman -Syu adobe-source-han-sans-jp-fonts otf-ipafont --noconfirm
    yay -Syu ttf-monapo --noconfirm
    sudo pacman -Syu ibus ibus-anthy --noconfirm
    yay -Syu ibus-bamboo --noconfirm
else
    echo "Currently this script only supports Arch, please install Bamboo & Anthy manually."
fi
