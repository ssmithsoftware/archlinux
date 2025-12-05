#!/bin/sh

set -e

# Get names of staged files added, copied, modified, or renamed. Exit if zero
files=$(git diff --cached --diff-filter=ACMR --name-only | sed 's/ /\\ /g')
[ -z $files ] && exit 0

# Format staged files
echo $files | xargs prettier --ignore-unknown --write >/dev/null

# Stage formatted files
echo $files | xargs git add >/dev/null
