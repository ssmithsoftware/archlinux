#!/bin/sh

# Show 256 terminal colors
for C in {0..255}; do
    tput setaf $C
    echo -n "$C "
done

tput sgr0
echo
