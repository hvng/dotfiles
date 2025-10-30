
#!/bin/bash

usage() {
    echo "Usage: $0 [-u] [-z] [-d] [-n] [-g] [-c] [-y] [-h] [-i]"
    echo -e "\t-u\tutilities: nvim, tmux, htop, ctags, xclip, ag, ..."
    echo -e "\t-z\tzsh"
    echo -e "\t-d\tdotfiles"
    echo -e "\t-g\tGolang (1.7)"
    echo -e "\t-c\tClang"
    echo -e "\t-y\tYarn (+nodejs)"
    echo -e "\t-h\tHugo"
    echo -e "\t-i\tIBus Bamboo & Anthy"
}

valid=0
install_dotfiles=0
install_common=0
install_zsh=0
install_golang=0
install_clang=0
install_hugo=0
install_ibusbamboo=0

while getopts czdgyhi flag; do
  case $flag in
    u)
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
    c)
      valid=1
      install_clang=1
      ;;
    y)
      valid=1
      install_yarn=1
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
    echo "Installing utilities"
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

if [[ $install_yarn = 1 ]]; then
    echo -e "\n---------"
    echo "Installing Yarn"
    echo "---------"
    bash setup/install_yarn.sh
fi

if [[ $install_golang = 1 ]]; then
    echo -e "\n---------"
    echo "Installing Golang"
    echo "---------"
    bash setup/install_golang.sh
fi

if [[ $install_clang = 1 ]]; then
    echo -e "\n---------"
    echo "Installing Clang"
    echo "---------"
    bash setup/install_clang.sh
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
