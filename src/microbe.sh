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
VERSION="0.2.0-SNAPSHOT"
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

function check_git_repository() {
    which curl >& /dev/null || error "Dependency missing: curl";
    local url="$1"
    debug "Checking: $url"
    curl -o /dev/null --head --silent --fail "$url"
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

function load_git_repository() {
    which git >& /dev/null || error "Dependency missing: git";
    local user="$1"
    local repo="$2"
    local url="$3"
    local src="$MICROBE/$user/$repo";

    set -e
    debug "microbe directory: $src"
    debug "plugin directory:  $dst"
    if [ -d "$src" ]; then
        verbose -n "  - Using package from Cache ...";
        set +e
        return 0;
    fi

    verbose "  - Cloning from `yellow "$url"` ..."
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

    verbose -n "  - Adding to Pathogen Bundles ... "
    set +e
    return 0
}

function load_zip_repository() {
    local user="$1"
    local repo="$2"
    local url="$3"
    local tmp="`mktemp -d`"
    local dst="$MICROBE/$user/$repo"

    mkdir -p "$MICROBE/$user"
    verbose -n "  - Getting ZIP from `yellow "$url"` ... "
    curl -Sso "$tmp/archive.zip" -L --fail "$url"
    local st="$?"
    if [[ "$st" != "0" ]]; then error "Failed ($st)."; fi
    success "OK."

    verbose -n "  - Extracting Archive to `yellow "$dst"` ... "
    unzip "$tmp/archive" -d "$tmp" 1> /dev/null
    if [[ "$?" != "0" ]]; then error "Failed."; fi
    mv "$tmp/$repo-master" "$dst"
    rm -rf "$tmp"
    success "OK."
    verbose -n "  - Adding to Pathogen Bundles ... "
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

function action_install_single() {
    local spec="$1"

    if [ -z "$spec" ]; then
        echo_red "Usage: $0 install <spec>" 1>&2;
        echo "<spec> is one of:" 1>&2
        echo "- <GitHub User>/<Repository>" 1>&2
        echo "- <vim-scripts Repository>" 1>&2
        echo "- git://..." 1>&2
        exit 1;
    fi

    # Data
    local user=""
    local repo=""
    local url=""
    local resolve="yes"
    local zip="yes"

    # Git Repository?
    if [ ${spec:0:6} == "git://" ] || [[ "$spec" == *@* ]] || [ ${spec:0:8} == "https://" ]; then
        local user="external"
        local repo="`basename "$spec" ".git"`"
        local url="$spec"
        local resolve="no"
        local zip="no"
        
    # GitHub Repository with given User?
    else if [[ "$spec" == */* ]]; then
        IFS="/" read -r user repo <<< "$spec"
        local url="$GITHUB_HTTPS/$user/$repo"

    # GitHub Repository of vim-scripts?
    else
        local user="$DEFAULT_USER"
        local repo="$spec"
        local url="$GITHUB_HTTPS/$user/$repo"
    fi; fi

    # Initialization
    action_init

    # Repository in Cache?
    local path="$MICROBE/$user/$repo"
    if [ -d "$path" ]; then
        verbose "* Using `yellow "$user/$repo"` from Cache.";
        link_microbe_repository "$user" "$repo"
        return 0;
    else if [ -d "$path.vim" ]; then
        verbose "* Using `yellow "$user/$repo.vim"` from Cache.";
        link_microbe_repository "$user" "$repo.vim"
        return 0;
    fi; fi

    echo "* Installing `yellow "$user/$repo"` ..."

    # Resolve?
    if [[ "$resolve" == "yes" ]]; then
        verbose -n "  - Resolving Package `yellow "$repo"` ... "
        checked_url=""
        for u in "" ".vim"; do
            if check_git_repository "$url$u"; then
                checked_url="$url$u";
                repo="$repo$u";
                break;
            fi
        done
        if [ -z "$checked_url" ]; then error "Could not find Repository."; fi
        success "OK."
    else 
        checked_url="$url"
    fi

    # Load Repository
    if [[ "$zip" == "yes" ]]; then
        zipUrl="$checked_url/archive/master.zip"
        load_zip_repository "$user" "$repo" "$zipUrl"
    else 
        load_git_repository "$user" "$repo" "$checked_url"
    fi
    
    #
    link_microbe_repository "$user" "$repo"

    # Delete everything that is not needed
    set -e
    for x in `find "$MICROBE/$user/$repo" -mindepth 1 -maxdepth 1 2> /dev/null`;
    do
        local n="`basename "$x"`"
        case "$n" in
            syntax|indent|autoload|colors|ftplugin|*.vim|doc|.git)
                ;;
            *)
                rm -r "$x"
                ;;
        esac
    done

    # Write Metadata
    echo "$spec" > "$MICROBE/$user/$repo/.microbe_spec"
    success "OK."
    set +e
}

function action_install() {
    while [ $# -gt 0 ]; do
        action_install_single "$1"
        shift
    done
}

function action_remove_single() {
    local spec="$1"
    IFS="/" read -r user pckg <<< "$spec"

    # Check
    if [ -z "$user" -a -z "$pckg" ]; then
        error "Usage: $0 install [<GitHub User>/]<Package>"
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
    set +e
}

function action_remove() {
    while [ $# -gt 0 ]; do
        action_remove_single "$1"
        shift
    done
}

function action_purge_single() {
    local spec="$1"
    IFS="/" read -r user pckg <<< "$spec"
    
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
    set +e
}

function action_purge() {
    while [ $# -gt 0 ]; do
        action_purge_single "$1"
        shift
    done
}

function action_update_single() {
    local specFile="$1"
    local repoDir="`dirname "$specFile"`"
    local repo="`basename "$repoDir"`"
    local userDir="`dirname "$repoDir"`"
    local user="`basename "$userDir"`"

    verbose -n "* Updating `yellow "$user/$repo"` ... "
    if [ -d "$repoDir/.git" ]; then
        cd "$repoDir"
        git pull -q
    else 
        local spec="`cat "$specFile"`"
        local installed="yes"
        if [ ! -L "$BUNDLE/${user}_${repo}" ]; then installed="no"; fi
        action_purge "$user/$repo" >& /dev/null
        action_install "$spec" 1> /dev/null
        if [ "$installed" == "no" ]; then rm "$BUNDLE/${user}_${repo}"; fi
    fi
    success "OK."
}

function action_update() {

    # Update all?
    if [ "$#" == "0" ]; then
        set -e
        for f in `find "$MICROBE" -mindepth 3 -maxdepth 3 -type f -name ".microbe_spec" 2> /dev/null | sort`; do
            action_update_single "$f"
        done
        set +e
    else
        while [ $# -gt 0 ]; do
            local spec="$1"
            IFS="/" read -r user pckg <<< "$spec"
        
            # Fallback to Default User?
            if [ -z "$pckg" ]; then
                pckg="$user"
                user="$DEFAULT_USER"
            fi
        
            # Update
            set -e
            local path="$MICROBE/$user/$pckg"
            if [ ! -e "$path/.microbe_spec" ]; then path="$path.vim"; fi
            if [ ! -e "$path/.microbe_spec" ]; then shift; continue; fi
            action_update_single "$path/.microbe_spec"
            set +e
            shift
        done
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
    for dir in `find "$MICROBE" -mindepth 3 -maxdepth 3 -type f -name ".microbe_spec" 2> /dev/null | sort`; do
        local repoDir="`dirname "$dir"`"
        local repo="`basename "$repoDir"`"
        local userDir="`dirname "$repoDir"`"
        local user="`basename "$userDir"`"
        
        local s="`du -sk "$repoDir"`"
        local kb=""
        local r=""
        read kb r <<< "$s"

        local installed="(not installed)"
        if [ -L "$BUNDLE/${user}_${repo}" ]; then local installed="    `green "(installed)"`"; fi
        local line="$(printf "%50s     %s     %6s    %s" "$user/`yellow "$repo"`" "$installed" "${kb}KB" "$repoDir")"

        verbose "$line"
    done
    set +e
}

# --------------------------------------------------------------------------
# Handlers
if [ -z "$COMMAND" ] || [[ "$COMMAND" == "help" ]]; then
    action_help
    exit 0;
fi

shift
case "$COMMAND" in
    "version")
        action_version
        ;;
    "init")
        action_init
        ;;
    "install")
        action_install "$@"
        ;;
    "remove")
        action_remove "$@"
        ;;
    "purge")
        action_purge "$@"
        ;;
    "update")
        action_update "$@"
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
