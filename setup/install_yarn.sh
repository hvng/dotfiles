#!/bin/bash

# Installs Yarn (and nodejs if needed)
if [[ `lsb_release -is` == "Arch" ]]; then
    sudo pacman -S yarn --noconfirm
elif [[ `lsb_release -is` == "Ubuntu" ]]; then
    sudo apt install yarn -y
else
    echo "Not supported, please install Hugo manually."
fi

echo "PATH=\"\$PATH:`yarn global bin`\"" >> ~/.bashrc
echo "PATH=\"\$PATH:`yarn global bin`\"" >> ~/.zshrc
