#!/bin/bash

# ----------------------------------------------------------------
# Utilities
function checkUrl() {
    which curl >& /dev/null || error "Dependency missing: curl";
    local url="$1"
    debug "Checking: $url"
    curl -o /dev/null --head --silent --fail "$url"
    local st="$?"
    debug "curl returned status $st."
    if [[ "$st" != "0" ]]; then return 1; fi
    return 0;
}

function parseSpec() {
    local spec="$1"
    local group=""
    local plugin=""
    local url=""
    local path=""
    local dispatch="zip"
    local resolve="yes"

    if [[ "$spec" == */* ]]; then
        IFS="/" read -r group plugin <<< "$1"
        local url="$GITHUB_HTTPS/$group/$plugin"
        local path="/archive/master.zip"
    else
        local group="$DEFAULT_GROUP"
        local plugin="$spec"
        local url="$GITHUB_HTTPS/$group/$plugin"
        local path="/archive/master.zip"
    fi

    if [ "$resolve" == "yes" ]; then
        local found="no"
        for ext in "" ".vim"; do
            if checkUrl "$url$ext"; then
                local url="$url$ext"
                local plugin="$plugin$ext"
                local found="yes"
                break;
            fi
        done
        if [ "$found" != "yes" ]; then
            fatal "Could not find Plugin: $group/$plugin"
        fi
    fi

    echo "$group $plugin $dispatch $url$path"
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
