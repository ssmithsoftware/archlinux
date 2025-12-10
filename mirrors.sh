#!/bin/sh

set -e

file=/etc/pacman.d/mirrorlist
prompt=$(cat <<-EOF
	Running this script will overwrite the contents of $file
	Are you sure you want to continue?
EOF
)
url='https://static.ssmithsoftware.com/archlinux/$repo/os/$arch'

read -p "$prompt (y/n): " input

case $input in
	[Yy]*) echo "Generating latest mirrors in $file. Please wait...";;
	[Nn]*) echo 'Exiting'; exit;;
	*) echo 'Invalid input.'; exit 1;;
esac

# Get top ten latest synchronized mirrors sorted by rate.
sudo reflector -c US,CA,GB -l 10 -p https --save $file --sort rate

echo "Appending $url to $file"
echo "Server = $url" | sudo tee -a $file >/dev/null
