#!/bin/bash

# Installs Yarn (and nodejs if needed)
sudo pacman -S yarn --noconfirm

echo "PATH=\"\$PATH:`yarn global bin`\"" >> ~/.bashrc
echo "PATH=\"\$PATH:`yarn global bin`\"" >> ~/.zshrc
