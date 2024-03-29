#!/bin/bash

# Create config
if [ ! -d "~/dotfiles/local" ]; then
    echo -n "Creating local directory... "
    cp -rf ~/dotfiles/template/ ~/dotfiles/local
    echo "DONE"
else
    echo "Local directory already exists"
fi

# Create symlinks, and back up current ones
echo -n "Linking dotfiles... "
local_dir=~/dotfiles/local
backup_dir=~/dotfiles/backup/$(date '+%Y-%m-%d_%H:%M:%S')
mkdir -p $backup_dir
# ln -sfb --suffix=.bak ~/dotfiles/local/.[^.]* ~/
# mv ~/.*.bak $backup_dir
# MacOS does not have backup options for ln command
for entry in $local_dir/.[^.]*
do
    file_name=$(basename $entry)
    if [ -f ~/$file_name ]; then
        mv ~/$file_name $backup_dir
    fi
done
ln -sf $local_dir/.[^.]* ~/
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
