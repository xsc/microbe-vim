#!/bin/bash
# <help>deactivate a plugin</help>

while [ $# -gt 0 ]; do
    pluginSpec="$1"
    spec=$(findPlugin "$pluginSpec");
    if [ -z "$spec" ]; then shift; continue; fi

    read -r group plugin <<< "$spec"
    path=$(bundlePath "$group" "$plugin")
    if [ -e "$path" -a ! -L "$path" ]; then fatal "Not a symbolic Link: $path"; 
    else
        verbose -n "Removing $(yellow "$group/$plugin") ... "
        rm -f "$path"
        success "OK."
    fi
    shift
done
