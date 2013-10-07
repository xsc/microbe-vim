#!/bin/bash

which git >& /dev/null || fatal "Dependency missing: git";

# --------------------------------------------------------------
# Parameters
group="$1"
plugin="$2"
url="$3"

if [ -z "$group" -o -z "$plugin" -o -z "$url" ]; then
    fatal "Usage: fetch.git <group id> <plugin id> <git repository>"
fi

# --------------------------------------------------------------
# Paths
dst=$(pluginPath "$group" "$plugin")
if [ -d "$dst" ]; then fatal "Directory $dst does already exist."; fi

verbose "- Cloning from $url ..."
if [[ "$VERBOSE" != "no" ]]; then
    verbose ""
    git clone --depth=1 "$url" "$dst"
    verbose ""
else
    set +e
    tmp="$(__mktemp)"
    trap 'rm -f "$tmp";' 0
    git clone --depth=1 "$url" "$dst" >& "$tmp";
    if [[ "$?" != "0" ]]; then
        cat "$tmp" 1>&2;
        exit 1;
    fi
    set -e
fi
set +e
