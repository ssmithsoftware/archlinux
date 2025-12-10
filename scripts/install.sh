#!/bin/sh
# Create symlinks in $HOME directory

set -e

dir=$(dirname "$(dirname "$(readlink -f "$0")")")
prompt='You must reboot to view your changes.'

cd $HOME
ln -fsv $dir/.bash_logout $dir/.bash_profile $dir/.bashrc \
	$dir/.editorconfig $dir/.gitconfig $dir/.gittemplate/ \
	$dir/.inputrc $dir/.prettierrc $dir/.profile $dir/.vimrc .

dir=$dir/.config

cd $XDG_CONFIG_HOME
ln -fsv $dir/hypr/ $dir/kitty/ \
	$dir/pacman/ $dir/uwsm/ $dir/waybar/ .

read -p "$prompt Would you like to reboot now? (y/n): " input
case $input in
	[Yy]*) echo 'Rebooting';;
	[Nn]*) echo 'Exiting'; exit;;
	*) echo "Invalid input. $prompt"; exit 1;;
esac

reboot
