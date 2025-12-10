#!/bin/sh
# Add dr9n mirrors and pacman hooks

dir=/etc/pacman.d
file=/etc/pacman.conf

if ! grep -qs '^\[dr9n\]$' $file; then
	echo "Adding dr9n mirrors to $file"

	sudo tee -a $file >/dev/null <<-EOF

		[dr9n]
		Server = https://static.ssmithsoftware.com/archlinux/\$repo/os/\$arch
	EOF
fi

sudo cp -rv $XDG_CONFIG_HOME/pacman/hooks/ $dir/hooks/
