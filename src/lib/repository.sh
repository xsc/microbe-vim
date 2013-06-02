#!/bin/bash

# ----------------------------------------------------------------
# Utilities
function parseSpec() {
    local spec="$1"
    local group=""
    local plugin=""

    if [[ "$spec" == */* ]]; then
        IFS="/" read -r group plugin <<< "$1"
    else
        local group="$DEFAULT_GROUP"
        local plugin="$spec"
    fi
    echo "$group $plugin"
}

# ----------------------------------------------------------------
# Repository Management

function pluginPath() {
    local group="$1"
    local plugin="$2"
    echo "$MICROBE/$group/$plugin"
}

function bundlePath() {
    local group="$1"
    local plugin="$2"
    echo "$BUNDLE/${group}_${plugin}"
}

function activatePlugin() {
    local group="$1"
    local plugin="$2"
    local path=$(pluginPath "$group" "$plugin")
    local dst=$(bundlePath "$group" "$plugin")

    if [ ! -d "$path" ]; then fatal "No such Plugin: $group/$plugin"; fi
    if ! ln -sf "$path" "$dst" 2> /dev/null; then
        fatal "Could not create symbolic Link at: $dst"
    fi
}

function deactivatePlugin() {
    local group="$1"
    local plugin="$2"
    local dst=$(bundlePath "$group" "$plugin")

    if [ -L "$dst" ]; then rm -f "$dst"; fi
}

# ----------------------------------------------------------------
# List
function listRepository() {
    set -e
    for dir in `find "$MICROBE" -mindepth 3 -maxdepth 3 -type f -name ".microbe_spec" 2> /dev/null | sort`; do
        local repoDir=$(dirname "$dir")
        local repo=$(basename "$repoDir")
        local userDir=$(dirname "$repoDir")
        local user=$(basename "$userDir")
        
        local s=$(du -sk "$repoDir")
        local kb=""
        local r=""
        read kb r <<< "$s"

        local installed=$(red "(not installed)")
        if [ -L "$BUNDLE/${user}_${repo}" ]; then local installed=$(green "(installed)"); fi
        verbose "$user/$(yellow "$repo")|$installed|${kb}KB|$repoDir"
    done
    set +e
}
