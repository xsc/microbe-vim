#!/bin/bash
# <help>remove a plugin from your file system</help>

while [ $# -gt 0 ]; do
    pluginSpec="$1"
    spec=$(findPlugin "$pluginSpec");
    if [ -z "$spec" ]; then shift; continue; fi

    read -r group plugin <<< "$spec"
    __run "remove" "$group/$plugin"

    path=$(pluginPath "$group" "$plugin")
    if [ -d "$path" ]; then
        verbose -n "Purging $(yellow "$group/$plugin") ... "
        rm -rf "$path"
        success "OK."
    fi

    shift
done
