#!/bin/bash

group="$1"
plugin="$2"

if [ -z "$group" -o -z "$plugin" ]; then
    fatal "Usage: plugin.deactivate <group id> <plugin id>"
fi

if [ -L "$(bundlePath "$group" "$plugin")" ]; then
    verbose -n "- Deactivating Plugin: $group/$plugin ... "
    deactivatePlugin "$group" "$plugin"
    success "OK."
fi

