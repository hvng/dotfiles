#!/bin/bash

if [[ `lsb_release -is` == "Arch" ]]; then
    sudo pacman -Syu ibus --noconfirm
    yay -Syu ibus-bamboo --noconfirm
else
    echo "Currently this script only supports Arch, please install IBus Bamboo manually."
fi