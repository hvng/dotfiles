#!/bin/bash

# Create config
if [ ! -d "$HOME/dotfiles/local" ]; then
    echo -n "Creating local directory... "
    cp -rf ~/dotfiles/template ~/dotfiles/local
    echo "DONE"
else
    echo "Local directory already exists"
fi

# Create symlinks, and back up current ones
echo -n "Linking dotfiles... "
backup_dir=$HOME/dotfiles/backup/$(date '+%Y-%m-%d_%H:%M:%S')/
mkdir -p $backup_dir
ln -sfb --suffix=.bak ~/dotfiles/local/.[^.]* $HOME/
mv $HOME/.*.bak $backup_dir
echo "DONE"

# Link neovim config to standard vimrc location
echo -n "Linking Neovim config... "
mkdir -p ~/.config/nvim
ln -sf ~/.vimrc ~/.config/nvim/init.vim
echo "DONE"

# Install plugins
echo -n "Setting up Neovim plugins... "
nvim +PlugUpdate +qall
echo "DONE"