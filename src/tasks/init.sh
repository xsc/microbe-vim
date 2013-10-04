#!/bin/bash
# <help>initialize pathogen and microbe</help>

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
        echo "call pathogen#infect()" >> "$HOME/.vimrc"
        cat "$HOME/.vimrc.bak" >> "$HOME/.vimrc"
        success "OK."
    fi
fi

set +e
