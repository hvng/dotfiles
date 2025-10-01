#
# hvng
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '


# append to the history file, don't overwrite it
shopt -s histappend

HISTSIZE=50000
HISTFILESIZE=50000


alias nvc="nvim ~/dotfiles/common/init.lua"
alias vc="nvim ~/dotfiles/common/.vimrc"
alias tc="nvim ~/dotfiles/common/.tmux.conf"
alias :q="exit"
alias :e="nvim"


case ${OSTYPE} in
    # For MacOS
    darwin*)
        # echo "Hi MacOS!"
    ;;

    # For Linux
    linux*)
        # Set environment variables if ibus exists
        if which ibus > /dev/null 2>&1 ; then
            export GTK_IM_MODULE=ibus
            export QT_IM_MODULE=ibus
            export XMODIFIERS=@im=ibus
        fi
    ;;
esac
