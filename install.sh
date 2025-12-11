#!/bin/sh

set -e

dir=$(dirname "$(readlink -f "$0")")
prompt='Reboot to view any desktop environment changes.'

# Create symlinks in current user's home directory
cd "$dir"/home/user/HOME/
ln -fsv "$PWD"/.* $HOME

cd ../XDG_CONFIG_HOME/
ln -fsv "$PWD"/* $XDG_CONFIG_HOME

# Include pacman drop-in configurations
file=/etc/pacman.conf

if ! grep -qs '^Include = /etc/pacman\.conf\.d/\*\.conf$' $file; then
	sudo sed -i '/^\[options\]$/a Include = /etc/pacman.conf.d/*.conf\n' $file

	echo 'Drop-in directory appended to pacman.conf'
fi

cd "$dir"/etc/
sudo cp -v "$PWD"/makepkg.conf.d/makepkg.conf /etc/makepkg.conf.d/
sudo cp -rv "$PWD"/pacman.conf.d/ /etc/
sudo cp -rv "$PWD"/pacman.d/hooks/ /etc/pacman.d/

# Copy reflector configuration and enable systemd service
sudo cp -v "$PWD"/xdg/reflector/reflector.conf /etc/xdg/reflector/
sudo systemctl enable reflector.service

read -p "$prompt Would you like to reboot now? (y/n): " input
case $input in
	[Yy]*) echo 'Rebooting'; reboot;;
	[Nn]*) echo 'Exiting';;
	*) echo "Invalid input. $prompt"; exit 1;;
esac
