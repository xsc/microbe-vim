#!/bin/bash

which curl >& /dev/null || error "Dependency missing: curl"; 

debug "curl:                 `which curl`"
debug "git:                  `which git`"
debug "microbe repository:   $MICROBE"
debug "home path:            $HOME"
debug "vim autoload path:    $AUTOLOAD"
debug "pathogen bundle path: $AUTOLOAD"
debug "pathogen path:        $PATHOGEN_VIM"
