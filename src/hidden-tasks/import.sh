#!/bin/bash

path="$1"

if [ -z "$path" ]; then path="$HOME/.vimrc"; fi
if [ ! -e "$path" ]; then fatal "No such file: $path"; fi

packages=$(grep "^\"bundle " "$path" | sed 's/^\"bundle //')

__run "install" $packages
