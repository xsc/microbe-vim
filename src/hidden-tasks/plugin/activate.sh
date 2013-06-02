#!/bin/bash

group="$1"
plugin="$2"

if [ -z "$group" -o -z "$plugin" ]; then
    fatal "Usage: plugin.activate <group id> <plugin id>"
fi

verbose -n "- Activating Plugin: $group/$plugin ... "
activatePlugin "$group" "$plugin"
success "OK."
