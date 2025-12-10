#!/bin/sh
# Get top ten latest synchronized mirrors sorted by download rate

set -e

file=/etc/pacman.d/mirrorlist
prompt=$(cat <<-EOF
	Running this script will overwrite the contents of $file
	Are you sure you want to continue?
EOF
)

read -p "$prompt (y/n): " input
case $input in
	[Yy]*) printf "Generating latest mirrors in $file\nPlease wait...\n";;
	[Nn]*) echo 'Exiting'; exit;;
	*) echo 'Invalid input.'; exit 1;;
esac

sudo reflector -c US,CA,GB -l 10 -p https --save $file --sort rate
echo 'Done'
