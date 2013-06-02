#!/bin/bash

# Repository Management

function pluginPath() {
    local group="$1"
    local plugin="$2"
    echo "$MICROBE/$group/$plugin"
}
