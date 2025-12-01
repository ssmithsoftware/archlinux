#!/bin/sh

set -e

dir="$(dirname "$(readlink -f "$0")")/"

cd $HOME
ln -s $dir.bash_logout $dir.bash_profile \
	$dir.bashrc $dir.inputrc $dir.prettierrc \
	$dir.profile $dir.vimrc .

cd $XDG_CONFIG_HOME
ln -s $dir.config/hypr/ $dir.config/kitty/ \
	$dir.config/waybar/ .

echo 'Reboot system to reload hyprland and view changes.'
