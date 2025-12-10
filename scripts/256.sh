#!/bin/sh

# Show 256 terminal colors
for color in {0..255}; do
	tput setaf $color
	echo -n "$color "
done

tput sgr0
echo
