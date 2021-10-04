#
# hvng
#

export LANG=en_US.UTF-8


source $HOME/dotfiles/thirdparty/antigen.zsh
antigen use oh-my-zsh
antigen bundle git
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle history-substring-search
antigen theme crunch.zsh-theme 
antigen apply

HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="false"
HIST_STAMPS="yyyy-mm-dd"
MODE_INDICATOR="%F{black}%K{white} <<< %k%f"
DISABLE_AUTO_TITLE="true"

HISTSIZE=50000
HISTFILESIZE=50000

autoload -Uz compinit
compinit


alias vc="nvim ~/.vimrc"
alias tc="nvim ~/.tmux.conf"
alias zc="nvim ~/.zshrc"
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
