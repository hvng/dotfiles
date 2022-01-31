
#!/bin/bash

usage() {
    echo "Usage: $0 [-c] [-z] [-d] [-n] [-g] [-h] [-i]"
    echo -e "\t-c\tcommon utilities: nvim, tmux, htop, ctags, xclip, ag, ..."
    echo -e "\t-z\tzsh"
    echo -e "\t-d\tdotfiles"
    echo -e "\t-g\tGolang (1.7)"
    echo -e "\t-h\tHugo"
    echo -e "\t-i\tIBus Bamboo & Anthy"
}

valid=0
install_dotfiles=0
install_common=0
install_zsh=0
install_golang=0
install_hugo=0
install_ibusbamboo=0

while getopts czdghi flag; do
  case $flag in
    c)
      valid=1
      install_common=1
      ;;
    z)
      valid=1
      install_zsh=1
      ;;
    d)
      valid=1
      install_dotfiles=1
      ;;
    g)
      valid=1
      install_golang=1
      ;;
    h)
      valid=1
      install_hugo=1
      ;;
    i)
      valid=1
      install_ibusbamboo=1
      ;;
    ?)
      valid=0
      ;;
  esac
done
shift $(( OPTIND - 1 ));

if [[ $valid = 0 ]]; then
    usage
    exit 2
fi

sudo -v

if [[ $install_common = 1 ]]; then
    echo -e "\n---------"
    echo "Installing common utilities"
    echo "---------"
    bash setup/install_common.sh
fi

if [[ $install_zsh = 1 ]]; then
    echo -e "\n---------"
    echo "Installing ZSH"
    echo "---------"
    bash setup/install_zsh.sh
fi

if [[ $install_dotfiles = 1 ]]; then
    echo -e "\n---------"
    echo "Linking dotfiles"
    echo "---------"
    bash setup/dotfiles_linker.sh
fi

if [[ $install_golang = 1 ]]; then
    echo -e "\n---------"
    echo "Installing Golang"
    echo "---------"
    bash setup/install_golang.sh
fi

if [[ $install_hugo = 1 ]]; then
    echo -e "\n---------"
    echo "Installing Hugo"
    echo "---------"
    bash setup/install_hugo.sh
fi

if [[ $install_ibusbamboo = 1 ]]; then
    echo -e "\n---------"
    echo "Installing IBus Bamboo"
    echo "---------"
    bash setup/install_ibus_bamboo_anthy.sh
fi

echo ""

exit 0
