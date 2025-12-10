#!/bin/sh

file=/etc/pacman.conf

if ! grep -qs '^\[dr9n\]$' $file; then
	sudo tee -a $file >/dev/null <<-EOF

		[dr9n]
		Server = https://static.ssmithsoftware.com/archlinux/\$repo/os/\$arch
	EOF
fi
