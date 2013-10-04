#!/bin/bash
# <help>fetch and activate the given plugins</help>

__run "init"

while [ $# -gt 0 ]; do
    pluginSpec="$1"
    spec=$(findPlugin "$pluginSpec")
    if [ -z "$spec" ]; then
        # Parse 
        if [ -z "$pluginSpec" ]; then shift; continue; fi
        spec=$(parseSpec "$pluginSpec")
        if [ -z "$spec" ]; then exit 1; fi
        read -r group plugin dispatch url <<< "$spec"

        # Fetch
        verbose "Installing $(yellow "$group/$plugin") ..."
        path=$(pluginPath "$group" "$plugin")
        if [ ! -d "$path" ]; then
            mkdir -p "$(dirname "$path")"
            __run "fetch.$dispatch" "$group" "$plugin" "$url"
            if [[ "$?" != "0" ]]; then exit 1; fi
            echo "$pluginSpec" > "$path/.microbe_spec"
        fi
    else
        read -r group plugin <<< "$spec"
        verbose "Using cached plugin $(yellow "$group/$plugin")."
    fi

    # Activate
    __run "plugin.activate" "$group" "$plugin"
    if [[ "$?" != "0" ]]; then exit 1; fi

    #
    shift
done
