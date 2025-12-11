#!/bin/bash
# Create symlinks in current user's home directory

set -e

dir=$(dirname "$(readlink -f "$0")")/home/user
prompt='Reboot to view any desktop environment changes.'

cd "$dir"/HOME
ln -fsv "$PWD"/.* $HOME

cd "$dir"/XDG_CONFIG_HOME
ln -fsv "$PWD"/* $XDG_CONFIG_HOME

read -p "$prompt Would you like to reboot now? (y/n): " input
case $input in
	[Yy]*) echo 'Rebooting';;
	[Nn]*) echo 'Exiting'; exit;;
	*) echo "Invalid input. $prompt"; exit 1;;
esac

reboot
