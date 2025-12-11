#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias grep='grep --color=auto'
alias ip='ip -color=auto'
alias ls='ls --color=auto'

export HISTCONTROL=ignoredups

# https://wiki.archlinux.org/title/Bash/Prompt_customization
blue="\[$(tput setaf 4)\]"
bold="\[$(tput bold)\]"
green="\[$(tput setaf 2)\]"
reset="\[$(tput sgr0)\]"

# Default
# PS1='[\u@\h \W]\$ '

# https://www.gnu.org/software/bash/manual/bash.html#Controlling-the-Prompt-1
PS1="$bold$green\u@\h$reset:$bold$blue\w$reset\$ "
