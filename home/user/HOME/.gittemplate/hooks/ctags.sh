#!/bin/sh

# Asynchronously pipe tracked files into ctags
git ls-files | ctags -L - >/dev/null 2>&1 &
