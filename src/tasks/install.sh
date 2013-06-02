#!/bin/bash

__run "init"

while [ $# -gt 0 ]; do
    pluginSpec="$1"
   
    # Parse 
    if [ -z "$pluginSpec" ]; then shift; continue; fi
    spec=$(parseSpec "$pluginSpec")
    if [ -z "$spec" ]; then exit 1; fi
    read -r group plugin dispatch url <<< "$spec"

    # Fetch
    verbose "Installing $(yellow "$group/$plugin") ..."
    path=$(pluginPath "$group" "$plugin")
    if [ -d "$path" ]; then
        verbose "- Using Cached Plugin."
    else
        __run "fetch.$dispatch" "$group" "$plugin" "$url"
        if [[ "$?" != "0" ]]; then exit 1; fi
    fi

    # Metadata
    echo "$pluginSpec" > "$path/.microbe_spec"

    # Activate
    __run "plugin.activate" "$group" "$plugin"
    if [[ "$?" != "0" ]]; then exit 1; fi

    #
    shift
done
