#!/bin/sh

set -e

dir="$(dirname "$(readlink -f "$0")")/"
prompt='You must reboot to view your changes.'

cd $HOME
ln -fsv $dir.bash_logout $dir.bash_profile $dir.bashrc \
	$dir.editorconfig $dir.gitconfig $dir.gittemplate/ \
	$dir.inputrc $dir.prettierrc $dir.profile $dir.vimrc .

cd $XDG_CONFIG_HOME
ln -fsv $dir.config/hypr/ $dir.config/kitty/ \
	$dir.config/uwsm/ $dir.config/waybar/ .

read -p "$prompt Would you like to reboot now? (y/n): " input

case $input in
	[Yy]*) echo 'Rebooting';;
	[Nn]*) echo 'Exiting'; exit;;
	*) echo "Invalid input. $prompt"; exit 1;;
esac

reboot
