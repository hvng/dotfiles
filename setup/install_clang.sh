#!/bin/bash

if [[ `lsb_release -is` == "Arch" ]]; then
    sudo pacman -Syu clang --noconfirm
else
    echo "Currently this script only supports Arch, please install Clang manually."
fi
