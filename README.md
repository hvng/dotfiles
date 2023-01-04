# dotfiles
Config files & setup scripts

<em>(Currently, only support for Arch Linux, Darwin or other Linux distros may not get a full installation when running this setup)</em>

## prerequisites
```
//  -Syu failed
sudo pacman -S archlinux-keyring

// Normally skip, cuz it's installed through arch installation.
sudo pacman -S --needed base-devel 

// lsb_release
sudo pacman -S lsb-release
```

## Setup

Clone to `$HOME/dotfiles`:

```
Usage: ./setup.sh [-c] [-z] [-d] [-g] [-y] [-h] [-i]
        -c      common utilities: nvim, tmux, htop, ctags, xclip, ag, ...
        -z      zsh
        -d      dotfiles
        -g      Golang (1.7)
        -y      Yarn (+nodejs)
        -h      Hugo
        -i      IBus Bamboo, IBus Anthy
```

## Structure

Dotfile linking is handled by `setup/dotfiles_linker.sh`.

1. Current configuration files (if existing) will be moved to a timestamped
   directory in `~/dotfiles/backup/` 
2. A copy of `~/dotfiles/template/` is made to `~/dotfiles/local/`
    - Mostly config files in `~/dotfiles/template/` source the settings stored in `~/dotfiles/common/` (global changes are tracked here) 
    - Local changes (usually workspace, env stuff) can then be made in `~/dotfiles/local/`
3. Symlinks are made to `~/dotfiles/local/*` from the `$HOME` directory
