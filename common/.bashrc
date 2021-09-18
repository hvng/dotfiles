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


alias vc="nvim ~/.vimrc"
alias tc="nvim ~/.tmux.conf"
alias zc="nvim ~/.zshrc"
alias :q="exit"
alias :e="nvim"
