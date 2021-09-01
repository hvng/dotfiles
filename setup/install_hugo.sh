#!/bin/bash

if [[ `lsb_release -is` == "Arch" ]]; then
    sudo pacman -Syu hugo --noconfirm
else
    echo "Currently this script only supports Arch, please install Hugo manually."
fi