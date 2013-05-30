#!/bin/bash

# --------------------------------------------------------------------------
#
# microbe: A pathogen-based Plugin Manager for GitHub-hosted Repositories.
#   Copyright (c) 2013 Yannick Scherer (yannick.scherer@gmail.com)
#
# --------------------------------------------------------------------------
# Microbe Data
VERSION="0.1.0-SNAPSHOT"
VIMDIR="$HOME/.vim"
AUTOLOAD="$VIMDIR/autoload"
BUNDLE="$VIMDIR/bundle"
PATHOGEN_VIM="$AUTOLOAD/pathogen.vim"
MICROBE_DATA="$HOME/.microbe"

# Remote Data
PATHOGEN_REMOTE="https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim"


# Script Data
SELF="`dirname "$0"`"
COMMAND="$1"
VERBOSE="$VERBOSE"
DEBUG="$DEBUG"
if [[ "$DEBUG" == "yes" ]]; then VERBOSE="yes"; fi
set -u

# --------------------------------------------------------------------------
# Colorize Output
GREEN="`tput setaf 2`"
YELLOW="`tput setaf 3`"
RED="`tput setaf 1`"
RESET="`tput sgr0`"

function green() { echo -n ${GREEN}${@}${RESET}; }
function red() { echo -n ${RED}${@}${RESET}; }
function yellow() { echo -n ${YELLOW}${@}${RESET}; }
function echo_green() { green $@; echo; }
function echo_red() { red $@; echo; }
function echo_yellow() { yellow $@; echo; }

# Output
function verbose() {
    if [[ "$VERBOSE" != "no" ]] || [ -z "$VERBOSE" ]; then
        echo "$@" 
    fi
}

function debug() {
    if [[ "$DEBUG" == "yes" ]]; then
        echo "[debug]" "$@"
    fi
}

function success() {
    verbose "`green "$@"`"
}

function error() { 
    echo_red $@ 1>&2; 
    exit 1;
}

# --------------------------------------------------------------------------
# Actions

function action_help() {
    echo "Usage: $0 <Command> [<Parameters> ...]"
}

function action_version() {
    verbose "microbe `yellow "$VERSION"` (bash $BASH_VERSION)"
    verbose ""
}

function action_init() {
    action_version

    which curl >& /dev/null || error "Dependency missing: curl"; 
    which git >& /dev/null || error "Dependency missing: git"; 

    verbose "Initializing ..." 
    debug "curl: `which curl`"
    debug "git:  `which git`"

    set -e
    if [ ! -d "$AUTOLOAD" ]; then
        verbose -n "* Initializing '$AUTOLOAD' ... "
        mkdir -p "$AUTOLOAD"
        success "OK."
    fi
    if [ ! -d "$BUNDLE" ]; then
        verbose -n "* Initializing '$BUNDLE' ... "
        mkdir -p "$BUNDLE"
        success "OK."
    fi
    if [ ! -s "$PATHOGEN_VIM" ]; then
        verbose -n "* Loading Pathogen ... "
        curl -Sso "$PATHOGEN_VIM" "$PATHOGEN_REMOTE" 
        success "OK."
    fi
    set +e

    success "Initialization complete."
}

# --------------------------------------------------------------------------
# Handlers
if [ -z "$COMMAND" ] || [[ "$COMMAND" == "help" ]]; then
    action_help
    exit 0;
fi

case "$COMMAND" in
    "version")
        action_version
        ;;
    "init")
        action_init
        ;;
    *)
        error "Unknown Action: $COMMAND";
        ;;
esac
