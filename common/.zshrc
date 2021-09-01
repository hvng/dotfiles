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