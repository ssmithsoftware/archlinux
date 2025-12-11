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

# Get the top ten out of 25 latest synchronized mirrors sorted by download rate
read -p "Would you like to retrieve the latest pacman mirrors? (y/n): " input
case $input in
	[Yy]*)
		echo 'Please wait...'
		sudo reflector -c US,CA,GB -l 25 -n 10 -p https \
			--save /etc/pacman.d/mirrorlist --sort rate --verbose

		echo 'Done';;
	*) echo 'Skipping mirrors';;
esac

read -p "$prompt Would you like to reboot now? (y/n): " input
case $input in
	[Yy]*) echo 'Rebooting'; reboot;;
	[Nn]*) echo 'Exiting';;
	*) echo "Invalid input. $prompt"; exit 1;;
esac
