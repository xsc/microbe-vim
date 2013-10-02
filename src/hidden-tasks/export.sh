#!/bin/bash

for f in $(listSpecFiles); do
    repoDir=$(dirname "$f")
    userDir=$(dirname "$repoDir")
    repo=$(basename "$repoDir")
    user=$(basename "$userDir")

    if [ -d "$BUNDLE/${user}_${repo}" ]; then
        echo "\"bundle $(cat "$f")"
    fi
done
