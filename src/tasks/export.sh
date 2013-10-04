#!/bin/bash
# <help>export all installed plugins to a file (or stdout)</help>

path="$1"

set -e

for f in $(listSpecFiles); do
    repoDir=$(dirname "$f")
    userDir=$(dirname "$repoDir")
    repo=$(basename "$repoDir")
    user=$(basename "$userDir")

    if [ -d "$BUNDLE/${user}_${repo}" ]; then
        if [ -z "$path" ]; then echo "\"bundle $(cat "$f")";
        else echo "\"bundle $(cat "$f")" >> "$path"; fi
    fi
done
