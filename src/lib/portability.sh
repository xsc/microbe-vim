#!/bin/bash

function __mktemp {
    case "$OSTYPE" in
        darwin*) mktemp "$@" "microbe";;
        *) mktemp "$@";;
    esac
}
