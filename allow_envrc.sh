#!/bin/zsh
PROJECTS=($(ls -d */))
MAIN_DIR=$(pwd)
RETURN_DIR=..

for project in "${PROJECTS[@]}" ; do
    if [[ -f "${MAIN_DIR}/${project}.envrc" ]]; then
        cd "${MAIN_DIR}/${project}"
        direnv allow
        cd "${RETURN_DIR}"
    fi
done
echo "run allowed .envrc !!"
