#!/bin/sh

file=/etc/pacman.conf
tag='<scott@ssmith.software>'

if ! grep -qs $tag $file; then
	sudo tee -a $file >/dev/null <<-EOF

		# Maintained by: Scott Smith $tag
		[custom]
		Include = /etc/pacman.d/mirrorlist
	EOF
fi
