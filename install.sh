#!/bin/sh

set -e

# Directory of this script
dir=$(dirname "$(readlink -f "$0")")

# Create symlinks in current user's home directory
cd "$dir"/home/USER/HOME/
ln -fsv "$PWD"/.* $HOME/

cd ../XDG_CONFIG_HOME/
ln -fsv "$PWD"/* $XDG_CONFIG_HOME/

# Include and install pacman drop-in configurations directory
path=/etc/pacman.conf

if ! grep -qs '^Include = /etc/pacman\.conf\.d/\*\.conf$' $path; then
	printf "\n[options]\nInclude = $path.d/*.conf" \
		| sudo tee -a $path
	echo
fi

path=$path.d

cd "$dir"$path/
sudo install -Dvm644 -t $path/ "$PWD"/*.conf

# Install pacman hooks and corresponding scripts
path=/etc/pacman.d

cd "$dir"$path/
sudo install -Dvm644 -t $path/hooks/ "$PWD"/hooks/*.hook
sudo install -vm755 -t $path/hooks/ "$PWD"/hooks/*.sh

# Get top 10 of 25 latest synchronized https mirrors sorted by download rate
read -p "Would you like to retrieve the latest pacman mirrors? (y/n): " input
case $input in
	[Yy]*)
		echo 'Please wait...'
		sudo reflector -c US,CA,GB -l 25 -n 10 -p https \
			--save $path/mirrorlist --sort rate --verbose

		echo 'Done';;
	*) echo 'Skipping mirrors';;
esac

# First time hyprland changes will be viewable after reboot
prompt='Reboot to view any desktop environment changes.'

read -p "$prompt Would you like to reboot now? (y/n): " input
case $input in
	[Yy]*) echo 'Rebooting'; reboot;;
	[Nn]*) echo 'Exiting';;
	*) echo "Invalid input. $prompt"; exit 1;;
esac
