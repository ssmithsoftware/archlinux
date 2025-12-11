#!/bin/bash
# Create symlinks in current user's home directory

set -e

dir=$(dirname "$(readlink -f "$0")")
prompt='Reboot to view any desktop environment changes.'

cd "$dir"/home/user/HOME/
ln -fsv "$PWD"/.* $HOME

cd ../XDG_CONFIG_HOME/
ln -fsv "$PWD"/* $XDG_CONFIG_HOME

# Include drop-in configuration directory to pacman.conf
file=/etc/pacman.conf

if ! grep -qs '^Include = /etc/pacman\.conf\.d/\*\.conf$' $file; then
	sudo sed -i '/^\[options\]$/a Include = /etc/pacman.conf.d/*.conf\n' $file \
		&& echo 'Drop-in directory appended to pacman.conf'
fi

# Copy drop-in directories and files
cd "$dir"

sudo cp -v etc/makepkg.conf.d/makepkg.conf /etc/makepkg.conf.d/
sudo cp -rv etc/pacman.conf.d/ /etc/
sudo cp -rv etc/pacman.d/hooks/ /etc/pacman.d/

read -p "$prompt Would you like to reboot now? (y/n): " input
case $input in
	[Yy]*) echo 'Rebooting'; reboot;;
	[Nn]*) echo 'Exiting';;
	*) echo "Invalid input. $prompt"; exit 1;;
esac
