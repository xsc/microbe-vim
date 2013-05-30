#!/bin/bash

# --------------------------------------------------------------------------
#
# microbe: A pathogen-based Plugin Manager for GitHub-hosted Repositories.
#   Copyright (c) 2013 Yannick Scherer (yannick.scherer@gmail.com)
#
# --------------------------------------------------------------------------
# Normalize Home
which readlink >& /dev/null
if [[ "$?" == "0" ]]
then
    h="`readlink -f "$HOME"`"
    HOME="$h"
fi

# Read Configuration
if [ -s "$HOME/.microbe.conf" ]; then
    eval "`cat "$HOME/.microbe.conf"`"
fi

# Microbe Data
VERSION="0.1.0"
VIMDIR="$HOME/.vim"
AUTOLOAD="$VIMDIR/autoload"
BUNDLE="$VIMDIR/bundle"
PATHOGEN_VIM="$AUTOLOAD/pathogen.vim"
MICROBE="$REPO"
if [ -z "$MICROBE" ]; then MICROBE="$HOME/.microbe"; fi
if [ -z "$COLORS" ]; then COLORS="yes"; fi

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

function echo_color() {
    if [[ "$COLORS" == "yes" ]]; then
        c="$1"
        shift
        echo -n ${c}${@}${RESET};
    else
        shift
        echo -n "$@";
    fi
}
function green() { echo_color "${GREEN}" "${@}"; }
function red() { echo_color "${RED}" "${@}"; }
function yellow() { echo_color "${YELLOW}" "${@}"; }
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

function link_microbe_repository() {
    local user="$1"
    local repo="$2"
    local src="$MICROBE/$user/$repo";
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
    local src="$MICROBE/$user/$repo";
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

    verbose -n "* Adding to Pathogen Bundles ... "
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

    debug "curl:                 `which curl`"
    debug "git:                  `which git`"
    debug "microbe repository:   $MICROBE"
    debug "home path:            $HOME"
    debug "vim autoload path:    $AUTOLOAD"
    debug "pathogen bundle path: $AUTOLOAD"
    debug "pathogen path:        $PATHOGEN_VIM"

    set -e
    for dir in "$AUTOLOAD" "$BUNDLE" "$MICROBE"; do
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
    local path="$MICROBE/$user/$pckg"
    if [ -d "$path" ]; then
        verbose "* Using `yellow "$user/$pckg"` from Cache.";
        link_microbe_repository "$user" "$pckg"
        return 0;
    fi
    
    if [ -d "$path.vim" ]; then
        verbose "* Using `yellow "$user/$pckg.vim"` from Cache.";
        link_microbe_repository "$user" "$pckg.vim"
        return 0;
    fi

    verbose -n "* Resolving Package `yellow "$pckg"` ... "
    repo=""
    for r in "$pckg" "$pckg.vim"
    do
        if check_github_repository "$user" "$r"; then
            repo="$r"
            break
        fi
    done
    if [ -z "$repo" ]; then error "Could not find Repository."; fi
    success "OK."

    # Load Repository
    verbose "* Loading `yellow "$user/$repo"` ..."
    load_github_repository "$user" "$repo"
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
        path="$MICROBE/$user/$r"
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
        path="$MICROBE/$user/$r"
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
    user="$1"
    pckg="$2"

    # Update all?
    if [ -z "$user" -a -z "$pckg" ]; then
        set -e
        for dir in `find "$MICROBE" -mindepth 1 -type d -name ".git"`; do
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
    else
        # Fallback to Default User?
        if [ -z "$pckg" ]; then
            pckg="$user"
            user="$DEFAULT_USER"
        fi
    
        # Update
        set -e
        for r in "$pckg" "$pckg.vim";
        do
            path="$MICROBE/$user/$r"
            if [ -d "$path/.git" ]; then
                verbose -n "* Updating `yellow "$user/$r"` ... "
                cd "$path"
                git pull -q 
                success "OK."

            fi
        done
        set +e
    fi
}

function action_update_pathogen() {
    if [ ! -s "$PATHOGEN_VIM" ]; then
        action_init;
    else
        verbose -n "* Updating Pathogen ... "
        mv "$PATHOGEN_VIM" "$PATHOGEN_VIM.bak"
        curl -Sso "$PATHOGEN_VIM" "$PATHOGEN_REMOTE" 
        if [[ "$?" != "0" ]]; then
            error "Could not download Pathogen."
            mv "$PATHOGEN_VIM.bak" "$PATHOGEN_VIM"
        else 
            rm "$PATHOGEN_VIM.bak"
            success "OK."
        fi
    fi
}

function action_list() {
    set -e
    for dir in `find "$MICROBE" -mindepth 1 -type d -name ".git" 2> /dev/null`; do
        local repoDir="`dirname "$dir"`"
        local repo="`basename "$repoDir"`"
        local userDir="`dirname "$repoDir"`"
        local user="`basename "$userDir"`"

        verbose -n "`yellow "$user/$repo"` "
        if [ -L "$BUNDLE/${user}_${repo}" ]; then
            verbose "`green "(installed)"`"
        else
            verbose "(not installed)"
        fi
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
        action_update "$2" "$3"
        ;;
    "update-pathogen")
        action_update_pathogen
        ;;
    "list")
        action_list
        ;;
    *)
        error "Unknown Action: $COMMAND";
        ;;
esac
