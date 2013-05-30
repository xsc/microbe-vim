#!/bin/bash

# --------------------------------------------------------------------------
#
# microbe: A pathogen-based Plugin Manager for GitHub-hosted Repositories.
#   Copyright (c) 2013 Yannick Scherer (yannick.scherer@gmail.com)
#
# --------------------------------------------------------------------------
# Normalize Home
which readlink >& /dev/null
if [[ "$?" != "0" ]]; then
    echo "Dependency missing: readlink." 1>&2;
    exit 1;
fi
HOME="`readlink -f "$HOME"`"

# Microbe Data
VERSION="0.1.0-SNAPSHOT"
VIMDIR="$HOME/.vim"
AUTOLOAD="$VIMDIR/autoload"
BUNDLE="$VIMDIR/bundle"
PATHOGEN_VIM="$AUTOLOAD/pathogen.vim"
MICROBE_REPO="$HOME/.microbe"

# Remote Data
PATHOGEN_REMOTE="https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim"
GITHUB_HTTPS="https://github.com"
DEFAULT_USER="vim-scripts"

# Script Data
SELF="`dirname "$0"`"
COMMAND="$1"
VERBOSE="$VERBOSE"
DEBUG="$DEBUG"
if [[ "$DEBUG" == "yes" ]]; then VERBOSE="yes"; fi

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
# Utilities

function check_github_repository() {
    which curl >& /dev/null || error "Dependency missing: curl";
    if [ -z "$1" -o -z "$2" ]; then return 1; fi
    local url="$GITHUB_HTTPS/$1/$2"
    debug "Checking: $url"
    curl -o /dev/null --head --silent --fail "$GITHUB_HTTPS/$1/$2"
    local st="$?"
    debug "curl returned status $st."
    if [[ "$st" != "0" ]]; then return 1; fi
    return 0;
}

function resolve_github_repository() {
    local user="$1"
    local pckg="$2"
    for r in "$pckg" "$pckg.vim"
    do
        if check_github_repository "$user" "$r"; then
            echo "$r"
            return 0;
        fi
    done
    return 1;
}

function link_microbe_repository() {
    local user="$1"
    local repo="$2"
    local src="$MICROBE_REPO/$user/$repo";
    local dst="$BUNDLE/${user}_${repo}"

    if [ ! -e "$dst" -o -L "$dst" ]; then
        ln -sf "$src" "$dst"
    else
        error "Cannot create Link at: $dst";
    fi
}

function load_github_repository() {
    which git >& /dev/null || error "Dependency missing: git";
    local user="$1"
    local repo="$2"
    local src="$MICROBE_REPO/$user/$repo";
    local url="$GITHUB_HTTPS/$user/$repo";

    set -e
    debug "microbe directory: $src"
    debug "plugin directory:  $dst"
    if [ -d "$src" ]; then
        verbose "* Using package from Cache.";
        link_microbe_repository "$user" "$repo"
        set +e
        return 0;
    fi

    verbose "* Cloning from `yellow "$url"` ..."
    if [[ "$VERBOSE" != "no" ]]; then
        verbose ""
        git clone --depth=1 "$url" "$src"
        verbose ""
    else
        set +e
        local tmp="`mktemp`"
        git clone --depth=1 "$url" "$src" >& "$tmp";
        if [[ "$?" != "0" ]]; then
            cat "$tmp" 1>&2;
            rm "$tmp";
            exit 1;
        fi
        rm  "$tmp";
        set -e
    fi

    verbose -n "* Creating Link ... "
    link_microbe_repository "$user" "$repo"
    success "OK."
    set +e
    return 0
}

# --------------------------------------------------------------------------
# Actions

function action_help() {
    echo "Usage: $0 <Command> [<Parameters> ...]"
}

function action_version() {
    verbose "microbe `yellow "$VERSION"` (bash $BASH_VERSION)"
}

function action_init() {

    which curl >& /dev/null || error "Dependency missing: curl"; 
    which git >& /dev/null || error "Dependency missing: git"; 

    debug "curl: `which curl`"
    debug "git:  `which git`"

    set -e
    for dir in "$AUTOLOAD" "$BUNDLE" "$MICROBE_REPO"; do
        if [ ! -d "$dir" ]; then
            verbose -n "* Initializing '`basename "$dir"`' ... "
            mkdir -p "$dir"
            success "OK."
        fi
    done
    if [ ! -s "$PATHOGEN_VIM" ]; then
        verbose -n "* Loading Pathogen ... "
        curl -Sso "$PATHOGEN_VIM" "$PATHOGEN_REMOTE" 
        success "OK."
    fi

    if [ ! -s "$HOME/.vimrc" ]; then
        verbose -n "* Creating '$HOME/.vimrc' ... "
        echo "set nocompatible" > "$HOME/.vimrc"
        echo "call pathogen#infect()" >> "$HOME/.vimrc"
        success "OK."
    else
        set +e
        grep -qx "call pathogen#infect()" "$HOME/.vimrc" >& /dev/null
        if [[ "$?" != "0" ]]; then
            set -e
            verbose -n "* Adding Pathogen to '$HOME/.vimrc' ... "
            mv "$HOME/.vimrc" "$HOME/.vimrc.bak"
            echo "set nocompatible" > "$HOME/.vimrc"
            echo "call pathogen#infect()" >> "$HOME/.vimrc"
            cat "$HOME/.vimrc.bak" >> "$HOME/.vimrc"
            success "OK."
        fi
    fi

    set +e
}

function action_install() {
    user="$1"
    pckg="$2"

    # Check
    if [ -z "$user" -a -z "$pckg" ]; then
        error "Usage: $0 install [<GitHub User>] <Package>"
    fi

    # Fallback to Default User?
    if [ -z "$pckg" ]; then
        pckg="$user"
        user="$DEFAULT_USER"
    fi

    # Initialization
    action_init

    # Find Repository
    local path="$MICROBE_REPO/$user/$pckg"
    if [ -d "$path" ]; then
        verbose "* Using `yellow "$user/$pckg"` from Cache.";
        link_microbe_repository "$user" "$pckg"
    else
        verbose -n "* Resolving Package `yellow "$pckg"` ... "
        repo="`resolve_github_repository "$user" "$pckg"`"
        if [ -z "$repo" ]; then error "Could not find Repository."; fi
        success "OK."

        # Load Repository
        verbose "* Loading `yellow "$user/$repo"` ..."
        load_github_repository "$user" "$repo"
    fi
}

function action_remove() {
    user="$1"
    pckg="$2"

    # Check
    if [ -z "$user" -a -z "$pckg" ]; then
        error "Usage: $0 install [<GitHub User>] <Package>"
    fi
    
    # Fallback to Default User?
    if [ -z "$pckg" ]; then
        pckg="$user"
        user="$DEFAULT_USER"
    fi

    # Remove
    set -e
    for r in "$pckg" "$pckg.vim";
    do
        path="$MICROBE_REPO/$user/$r"
        if [ -d "$path" ]; then
            verbose -n "* Removing `yellow "$user/$r"` ... "
            if [ -L "$BUNDLE/${user}_${r}" ]; then rm "$BUNDLE/${user}_${r}"; fi
            success "OK."

        fi
    done
    verbose "* Removed `yellow "$pckg"`."
    set +e
}

function action_purge() {
    user="$1"
    pckg="$2"

    # Check
    if [ -z "$user" -a -z "$pckg" ]; then
        error "Usage: $0 install [<GitHub User>] <Package>"
    fi
    
    # Fallback to Default User?
    if [ -z "$pckg" ]; then
        pckg="$user"
        user="$DEFAULT_USER"
    fi
    
    # Remove
    set -e
    for r in "$pckg" "$pckg.vim";
    do
        path="$MICROBE_REPO/$user/$r"
        if [ -d "$path" ]; then
            verbose -n "* Purging `yellow "$user/$r"` ... "
            rm -rf "$path"
            if [ -L "$BUNDLE/${user}_${r}" ]; then rm "$BUNDLE/${user}_${r}"; fi
            success "OK."

        fi
    done
    verbose "* Purged `yellow "$pckg"`."
    set +e
}

function action_update() {
    set -e
    for dir in `find "$MICROBE_REPO" -mindepth 1 -type d -name ".git"`; do
        local repoDir="`dirname "$dir"`"
        local repo="`basename "$repoDir"`"
        local userDir="`dirname "$repoDir"`"
        local user="`basename "$userDir"`"

        verbose -n "* Updating `yellow "$user/$repo"` ... "
        cd "$repoDir"
        git pull -q
        success "OK."
    done
    set +e
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
    "install")
        action_install "$2" "$3"
        ;;
    "remove")
        action_remove "$2" "$3"
        ;;
    "purge")
        action_purge "$2" "$3"
        ;;
    "update")
        action_update
        ;;
    *)
        error "Unknown Action: $COMMAND";
        ;;
esac
