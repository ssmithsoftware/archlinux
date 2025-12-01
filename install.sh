#!/bin/sh

cd "$(dirname "$(readlink -f $0)")/"

# Add symlinks to user home directory
ln -s .bash_logout .bash_profile .bashrc .inputrc .pretterrc .profile .vimrc $HOME
# ln -s .config/hypr/ .config/kitty/ .config/waybar/ $XDG_CONFIG_HOME
