#!/bin/bash

if [[ `lsb_release -is` == "Arch" ]]; then
    sudo pacman -Syu hugo --noconfirm
elif [[ `lsb_release -is` == "Ubuntu" ]]; then
    sudo apt-get install hugo -y
else
    echo "Currently this script only supports Arch, please install Hugo manually."
fi
