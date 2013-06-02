#!/bin/bash

# --------------------------------------------------------------
# Parameters
group="$1"
plugin="$2"
url="$3"

if [ -z "$group" -o -z "$plugin" -o -z "$url" ]; then
    fatal "Usage: install.zip <group id> <plugin id> <zip url>"
fi

# --------------------------------------------------------------
# Paths
dst=$(pluginPath "$group" "$plugin")
if [ -d "$dst" ]; then fatal "Directory $dst does already exist."; fi
tmp=$(mktemp -d)
trap 'rm -r "$tmp";' 0

# --------------------------------------------------------------
# Download & Extract
verbose -n "- Getting ZIP from $(yellow "$url") ... "
if ! curl -Sso "$tmp/archive.zip" -L --fail "$url" >& /dev/null; then fatal "Download failed."; fi
success "OK."

verbose -n "- Extracting Archive to $(yellow "$dst") ... "
unzip "$tmp/archive.zip" -d "$tmp" 1> /dev/null
if [[ "$?" != "0" ]]; then error "Failed."; fi
find "$tmp" -maxdepth 1 -mindepth 1 -type d -name "*-master" -exec "mv" \{\} "$dst" \;
success "OK."

# --------------------------------------------------------------
exit 0
