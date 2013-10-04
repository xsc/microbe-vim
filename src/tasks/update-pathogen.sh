#!/bin/bash
# <help>fetch the latest pathogen version</help>

if [ ! -s "$PATHOGEN_VIM" ]; then
    __run "init"
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
