#!/bin/bash

set -e
if [ "$#" == "0" ]; then
    plugins=$(\
        for f in $(find "$MICROBE" -mindepth 3 -maxdepth 3 -type f -name ".microbe_spec" 2> /dev/null | sort); do\
            p=$(dirname "$f");\
            echo "$(basename $(dirname "$p"))/$(basename "$p")";\
        done\
    );
    __run "update" $plugins
else
    while [ $# -gt 0 ]; do
        pluginSpec="$1"
        spec=$(findPlugin "$pluginSpec");
        if [ -z "$spec" ]; then shift; continue; fi

        # Parse 
        read -r group plugin <<< "$spec"

        # Update
        path=$(pluginPath "$group" "$plugin")
        if [ ! -d "$path" ]; then shift; continue; fi
        if [ ! -d "$path/.git" ]; then
            verbose -n "Updating $(yellow "$group/$plugin") ... "
            mv "$path" "$path@bak"
            if __run "install" "$(cat "$path@bak/.microbe_spec")" 1> /dev/null; then
                rm -rf "$path@bak"
                success "OK."
            else
                mv "$path@bak" "$path"
                verbose ""
                fatal "Failed."
            fi
        else
            verbose "Updating $(yellow "$group/$plugin") ..."
            cd "$path"
            verbose ""
            git pull
            verbose ""
            cd "$CWD"
        fi

        shift
    done
fi
set +e

