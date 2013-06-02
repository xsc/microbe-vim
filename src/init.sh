#!/bin/bash

# Checks
if [ ! -d "$HOME" ]; then
    echo "Home Directory does not exist. \$HOME = $HOME" 1>&2;
    exit 1;
fi

# Global Data
VIMDIR="$HOME/.vim"
AUTOLOAD="$VIMDIR/autoload"
BUNDLE="$VIMDIR/bundle"
PATHOGEN_VIM="$AUTOLOAD/pathogen.vim"
if [ -z "$MICROBE" ]; then MICROBE="$HOME/.microbe"; fi
if [ -z "$COLORS" ]; then COLORS="yes"; fi

# Remote Data
PATHOGEN_REMOTE="https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim"
GITHUB_HTTPS="https://github.com"
DEFAULT_GROUP="vim-scripts"

# Script Data
SELF=$(cd $(dirname "$0") && pwd)
VERBOSE="$VERBOSE"
DEBUG="$DEBUG"
if [[ "$DEBUG" == "yes" ]]; then VERBOSE="yes"; fi
